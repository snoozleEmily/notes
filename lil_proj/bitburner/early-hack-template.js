/** @param {NS} ns **/
export async function main(ns) {
  // Prefer an explicit argument; 
  // otherwise default to the hostname where this script runs
  const argTarget = ns.args[0];
  const host = ns.getHostname();
  const purchased = ns.getPurchasedServers();

  let target = argTarget || host;

  // If we ended up with home or a purchased server as the target, require an argument
  if (target === "home" || purchased.includes(target)) {
    ns.tprint("Usage: run script.js <target>    (cannot use 'home' or a purchased server as target)");
    return;
  }

  ns.tprint(`Attacking target: ${target}`);

  const moneyThresh = ns.getServerMaxMoney(target);
  const securityThresh = ns.getServerMinSecurityLevel(target);

  if (ns.fileExists("BruteSSH.exe", "home")) ns.brutessh(target);
  ns.nuke(target);

  while (true) {
    if (ns.getServerSecurityLevel(target) > securityThresh) {
      await ns.weaken(target);
    }
    else if (ns.getServerMoneyAvailable(target) < moneyThresh) {
      await ns.grow(target);
    }
    else {
      await ns.hack(target);
    }
  }
}
