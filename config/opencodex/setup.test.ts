import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

test("setup isolates runtime state and preserves local edits when repeated", () => {
    const home = mkdtempSync(join(tmpdir(), "opencodex-setup-test-"));
    const runtime = join(home, ".opencodex");
    const env = { ...process.env, HOME: home, OPENCODEX_HOME: runtime, XDG_STATE_HOME: join(home, "state") };
    const setup = () => Bun.spawnSync([process.execPath, join(import.meta.dir, "setup.ts")], {
        cwd: tmpdir(), env, stdout: "ignore", stderr: "pipe",
    });
    try {
        const first = setup();
        expect(first.stderr.toString()).toBe("");
        expect(first.exitCode).toBe(0);
        const config = join(runtime, "config.json");
        expect(statSync(config).mode & 0o777).toBe(0o600);
        const edited = JSON.stringify({ ...JSON.parse(readFileSync(config, "utf8")), localSetting: "keep" });
        writeFileSync(config, edited);
        expect(setup().exitCode).toBe(0);
        expect(readFileSync(config, "utf8")).toBe(edited);
        expect(existsSync(join(home, ".codex"))).toBe(false);
        expect(existsSync(join(home, ".claude"))).toBe(false);
    } finally {
        rmSync(home, { recursive: true, force: true });
    }
});
