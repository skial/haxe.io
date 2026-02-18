import { readdir } from "fs/promises";
import path, { basename, extname, join } from "path";

export default async function (data) {
    let workingDir = process.cwd();
    let gamejams = ["ld"];
    let entries = await Promise.all( gamejams.map( async function(path) {
        let result = await readdir(join(workingDir, 'src', path), { withFileTypes: true });
        return result;
    } ) );
    entries = entries.flat(1);
    let modules = {};
    for (let i = 0; i < entries.length; i++) {
        const entry = entries[i];
        if (entry.isFile() && extname(entry.name) === ".js") {
            let filePath = join(entry.parentPath, entry.name);
            let pathInfo = path.parse(entry.parentPath);
            let fileInfo = path.parse(filePath);
            let key = pathInfo.base + fileInfo.name.replace(".11tydata", "");
            let module = await import(filePath);
            modules[key] = module.default();
        }
    }

    return {gamejam:modules};
}