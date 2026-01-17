export class FsaFS {
  constructor(Module) {
    this.Module = Module;
    this.pending = [];
  }

  async setMods(mods) {
    if (!Array.isArray(mods)) {
      return;
    }
    const FS = this.Module.FS;
    const PATH = this.Module.PATH;
    FS.mkdir('/mods');
    for (const mod of mods) {
      FS.writeFile(PATH.join2('/mods', mod.name), new Uint8Array(await mod.arrayBuffer()), { canOwn: true });
      // console.log(mod);
    }
  }

  persistfs(cb) {
    const FS = this.Module.FS;
    if (this.pending.length > 0) {
      this.pending.push(cb);
      return;
    } else {
      this.pending.push(cb);
    }

    setTimeout(() => {
      FS.syncfs(false, (err) => {
        if (err) {
          console.error(err);
        } else {
          this.pending.forEach(p => p());
        }
        this.pending = [];
      });
    }, 1000);
  }
}
