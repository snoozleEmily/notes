/** @param {NS} ns **/
export async function main(ns) {
  ns.disableLog("sleep")

  // if true,  ignores servers with Root Access
  // if false, ensures all vulnerable servers are being attacked 
  const SKIP_ROOTED = false;

  function getProgCount() {
    let count = 0;
    const progs = ["BruteSSH.exe", "FTPCrack.exe", "relaySMTP.exe", "HTTPWorm.exe", "SQLInject.exe"];
    for (const prog of progs) {
      if (ns.fileExists(prog, "home")) count++;
    }
    return count;
  }

  function scanAll(start = "home") {
    const visited = new Set();
    const stack = [start];
    const all = [];

    while (stack.length > 0) {
      const host = stack.pop();
      if (visited.has(host)) continue;
      visited.add(host);
      all.push(host);

      for (const n of ns.scan(host)) {
        if (!visited.has(n)) stack.push(n);
      }
    }
    return all;
  }

  const servers = scanAll();
  const pending = [];

  for (const s of servers) {
    if (s === "home" || s.startsWith("pserv-")) continue;

    if (SKIP_ROOTED && ns.hasRootAccess(s)) {
      // ns.tprint(`[SKIP] ${s}: Already have Root Access.`); // DEBUG
      continue;
    }

    const reqLvl = ns.getServerRequiredHackingLevel(s);
    const reqPorts = ns.getServerNumPortsRequired(s);
    const myLvl = ns.getHackingLevel();
    const myProgs = getProgCount();

    if (myLvl >= reqLvl && myProgs >= reqPorts) {
      ns.tprint(`[SUCCESS] ${s} is vulnerable! (Lvl: ${reqLvl}, Ports: ${reqPorts})`);
      breaching(ns, s);
    } else {
      let reason = "";
      // if (myLvl < reqLvl) reason += `Level too low (${myLvl}/${reqLvl}). `;
      if (myProgs < reqPorts) {
        reason += `Need more ports (${myProgs}/${reqPorts}).`
        ns.tprint(`[DEFER] ${s} -> ${reason}`);
      };
      
      pending.push({ server: s, reqLvl, reqPorts });
    }
  }

  if (pending.length === 0) {
    ns.tprint("All known servers are already being hacked.");
    return;
  }

  let lastLevel = ns.getHackingLevel();
  let lastProgs = getProgCount();

  while (pending.length > 0) {
    await ns.sleep(2000); 

    // Refresh current status 
    const currentLvl = ns.getHackingLevel();
    const currentProgs = getProgCount();

    // If nothing changed, loop back to sleep
    if (currentLvl <= lastLevel && currentProgs <= lastProgs) continue;

    if (currentLvl > lastLevel) ns.tprint(`[LEVEL UP]: ${lastLevel} -> ${currentLvl}`);
    if (currentProgs > lastProgs) ns.tprint(`[SOFTWARE UPDATE]: Programs: ${currentProgs}`);

    lastLevel = currentLvl;
    lastProgs = currentProgs;

    // which servers became available based on NEW stats
    for (let i = pending.length - 1; i >= 0; i--) {
      const target = pending[i];

      if (currentLvl >= target.reqLvl && currentProgs >= target.reqPorts) {
        ns.tprint(`[UNLOCKED]: ${target.server} is now hackable!`);
        ns.toast(`Unlocked: ${target.server}`, "success");

        breaching(ns, target.server);
        pending.splice(i, 1); 
      }
    }
  }

  ns.tprint("All known servers have been breached. System idle.");
}

function breaching(ns, target) { // Open ports based on owned files
  if (ns.fileExists("BruteSSH.exe", "home")) ns.brutessh(target);
  if (ns.fileExists("FTPCrack.exe", "home")) ns.ftpcrack(target);
  if (ns.fileExists("relaySMTP.exe", "home")) ns.relaysmtp(target);
  if (ns.fileExists("HTTPWorm.exe", "home")) ns.httpworm(target);
  if (ns.fileExists("SQLInject.exe", "home")) ns.sqlinject(target);

  try { // Get Root Access
    ns.nuke(target);
    ns.tprint(`[ROOTED] ${target} successfully nuked.`);
  } catch (e) {
    ns.tprint(`[ERROR] Failed to nuke ${target}.`);
    return;
  }

  // Launch the attack script
  if (ns.fileExists("launcher.js", "home")) {
    ns.run("launcher.js", 1, "earlyHackTemp.js", target);
  } else {
    ns.tprint(`[WARNING] No launcher.js found on home. ${target} remains idle.`);
  }
}

// ----- Util -----
function getPath(ns, target) {
  const queue = [["home"]];
  const visited = new Set(["home"]);
  while (queue.length > 0) {
    const path = queue.shift();
    const host = path[path.length - 1];
    if (host === target) return path;
    for (const neighbor of ns.scan(host)) {
      if (!visited.has(neighbor)) {
        visited.add(neighbor);
        queue.push([...path, neighbor]);
      }
    }
  }
  return null;
}