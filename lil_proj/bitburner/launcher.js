/** @param {NS} ns **/
export async function main(ns) {
  // run launcher.js <script> [host] [script-arg1] [script-arg2] ...
  const script = ns.args[0];
  const runHost = ns.args[1] || ns.getHostname();
  const scriptArgs = ns.args.slice(2);

  // Ensure script exists on the host before measuring RAM
  if (!ns.fileExists(script, runHost)) {
    ns.tprint(`The file 'early-hack-template.js' was not found at ${runHost}`)
    ns.tprint(`[RUNNING] scp early-hack-template.js ${runHost}`)
    ns.scp(script, runHost);
  }

  if (!script) {
    ns.tprint("Usage: run launcher.js <script> [host] [script-args...]");
    return;
  }

  // How much RAM the script needs per thread on the chosen host:
  const ramPerThread = ns.getScriptRam(script, runHost);
  const maxRam = ns.getServerMaxRam(runHost);
  const usedRam = ns.getServerUsedRam(runHost);
  const availRam = Math.max(0, maxRam - usedRam);

  const threads = Math.floor(availRam / ramPerThread);

  if (threads < 1) {
    ns.tprint(`Not enough RAM on ${runHost} to run ${script}. Available: ${availRam} GB, needed: ${ramPerThread} GB`);
    return;
  }

  ns.tprint(`Launching ${script} on ${runHost} with ${threads} thread(s). (avail ${availRam} GB, per-thread ${ramPerThread} GB)`);
  ns.exec(script, runHost, threads, ...scriptArgs);
}