/** @param {NS} ns **/
export async function main(ns) {
  function scanAll(start = "home") {
    const visited = new Set();
    const stack = [start];
    const all = [];
    
    while (stack.length > 0) {
      const host = stack.pop();
      if (visited.has(host)) continue;
      visited.add(host);
      all.push(host);
      for (const n of ns.scan(host)) stack.push(n);
    }
    return all;
  }

  const servers = scanAll();
  
  for (const s of servers) {
    if (s === "home") continue; // don't kill the wiper itself

    ns.killall(s);
    const files = ns.ls(s, ".js");
    for (const f of files) {
      ns.rm(f, s);
    }
  }
  ns.tprint("WIPE COMPLETE: All remote scripts stopped and deleted.");
}