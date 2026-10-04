// Seed portable defaults; mutable provider/auth/runtime files stay outside dotfiles.
import { chmodSync, constants, copyFileSync, existsSync, mkdirSync, readlinkSync, symlinkSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const directory = import.meta.dir;
const dotfiles = join(directory, "../..");
const home = process.env.OPENCODEX_HOME || join(homedir(), ".opencodex");
const state = join(process.env.XDG_STATE_HOME || join(homedir(), ".local/state"), "opencodex");
const secretFile = process.env.OPENCODEX_ENV_FILE || join(state, "secrets.env");
const service = process.argv.slice(2);
if (service.some(arg => arg !== "--service")) throw new Error("Usage: ocx-setup [--service]");
const label = "com.dotfiles.opencodex";
const target = `gui/${process.getuid!()}`;
function run(command: string[], options: { env?: Record<string, string | undefined>; stdin?: string } = {}): void {
    const result = Bun.spawnSync(command, {
        cwd: directory, stdout: "inherit", stderr: "inherit", env: options.env,
        stdin: options.stdin === undefined ? "ignore" : Buffer.from(options.stdin),
    });
    if (result.exitCode !== 0) throw new Error(`Command failed: ${command[0]} (exit ${result.exitCode})`);
}
if (service.length) {
    if (process.platform !== "darwin") throw new Error("--service installs a Mac LaunchAgent; on Linux run ocx start");
    const active = Bun.spawnSync(["launchctl", "print", `${target}/${label}`], { stdout: "ignore", stderr: "ignore" });
    if (active.exitCode === 0) throw new Error("Drain requests and boot out the OpenCodex LaunchAgent before configuring it");
    if (!existsSync(secretFile)) throw new Error(`Create the private provider environment file first: ${secretFile}`);
}
run([process.execPath, "install", "--frozen-lockfile"]);
mkdirSync(home, { recursive: true, mode: 0o700 });
chmodSync(home, 0o700);
const config = join(home, "config.json");
if (!existsSync(config)) copyFileSync(join(directory, "config.json"), config, constants.COPYFILE_EXCL);
chmodSync(config, 0o600);
mkdirSync(join(home, "codex"), { recursive: true, mode: 0o700 });
mkdirSync(state, { recursive: true, mode: 0o700 });
chmodSync(state, 0o700);
const bin = join(homedir(), ".local/bin");
mkdirSync(bin, { recursive: true });
for (const name of ["ocx", "ocx-setup"]) {
    const path = join(bin, name);
    const source = join(dotfiles, "bin", name);
    try { symlinkSync(source, path); }
    catch (error) {
        if ((error as NodeJS.ErrnoException).code !== "EEXIST") throw error;
        if (readlinkSync(path) !== source) throw new Error(`Preserving an existing command; resolve the conflict before setup: ${path}`);
    }
}
if (service.length) {
    const env = {
        HOME: homedir(), OPENCODEX_HOME: home, CODEX_HOME: join(home, "codex"),
        OPENCODEX_CODEX_SHIM_AUTO_RESTORE: "0",
        PATH: `${dirname(process.execPath)}:${bin}:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`,
    };
    const command = [process.execPath, `--env-file=${secretFile}`, join(directory, "node_modules/@bitkyc08/opencodex/src/cli/index.ts")];
    const agent = join(homedir(), "Library/LaunchAgents", `${label}.plist`);
    mkdirSync(dirname(agent), { recursive: true });
    const plist = {
        Label: label, ProgramArguments: [...command, "start", "--port", "10101"],
        WorkingDirectory: home, EnvironmentVariables: env,
        RunAtLoad: true, KeepAlive: true, AbandonProcessGroup: false,
        ThrottleInterval: 30, ExitTimeOut: 31 * 60, Umask: 0o077,
        StandardOutPath: join(state, "opencodex.log"), StandardErrorPath: join(state, "opencodex.err.log"),
    };
    run(["plutil", "-convert", "xml1", "-o", agent, "-"], { stdin: JSON.stringify(plist) });
    run(["launchctl", "bootstrap", target, agent]);
    run([...command, "ready", "--wait", "--timeout", "45"], { env: { ...process.env, ...env } });
    run([...command, "sync"], { env: { ...process.env, ...env } });
}
console.log(`OpenCodex configured at ${home}; existing runtime settings preserved.`);
