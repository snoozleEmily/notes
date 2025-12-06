/** @param {NS} ns **/
export async function main(ns) {
  ns.disableLog("sleep");
  
  // ----- Recursive network scan -----
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

  // Build our initial watch list
  for (const s of servers) {
    const req = ns.getServerRequiredHackingLevel(s);
    const lvl = ns.getHackingLevel();
    if (req > lvl) {
      pending.push({ server: s, req });
    }
  }

  if (pending.length === 0) {
    ns.tprint("All known servers are already hackable.");
    return;
  }

  ns.tprint(`Tracking ${pending.length} servers until they become hackable...`);

  let lastLevel = ns.getHackingLevel();

  while (pending.length > 0) {
    await ns.sleep(300); // very light, only wake to check level

    const lvl = ns.getHackingLevel();
    if (lvl <= lastLevel) continue;

    ns.tprint(`[DEBUG]: Hacking level increased from ${lastLevel} to ${lvl}`);
    lastLevel = lvl;

    // Check which servers became available
    for (let i = pending.length - 1; i >= 0; i--) {
      const { server, req } = pending[i];
      if (lvl >= req) {
        const path = getPath(ns, server).join(" -> ");
        const msg = `[READY]: ${server} is now hackable! (Level ${lvl} >= ${req}) | Path: ${path}`;
        ns.tprint(msg);
        ns.toast(msg, "success");
        pending.splice(i, 1);
      }
    }
    ns.tprint("No new servers are hackable. You're still stupid!");
  }

  ns.tprint("All monitored servers are now hackable. Monitor finished.");
  ns.tprint("Run 'hackLvlTargetMonitor.js' from 'home' again.")
}

// ----- util -----
// Returns the path as an array of hostnames: ["home", "...", target]
function getPath(ns, target) {
  const queue = [["home"]];
  const visited = new Set(["home"]);

  while (queue.length > 0) {
    const path = queue.shift();
    const host = path[path.length - 1];

    if (host === target) {
      return path;
    }

    for (const neighbor of ns.scan(host)) {
      if (!visited.has(neighbor)) {
        visited.add(neighbor);
        queue.push([...path, neighbor]);
      }
    }
  }
  return null; // unreachable
}