import mdit from 'markdown-it';
import md_abbr from 'markdown-it-abbr';
import md_anchor from 'markdown-it-anchor';
import md_attrs from 'markdown-it-attrs';
import { full as md_emoji } from 'markdown-it-emoji';
import md_footnote from 'markdown-it-footnote';
import twemoji from 'twemoji';
import { RenderPlugin } from "@11ty/eleventy";
import webc from '@11ty/eleventy-plugin-webc';
import fs from "node:fs/promises";
import path from "node:path";
import * as sass from "sass";
import { DateTime } from "luxon";

export default function(config) {
    function dateSort(a, b) {
        let ad = a.page.date;
        let bd = b.page.date;

        if (Object.hasOwn(a.data, "payload")) {
            ad = (a.data.payload.published ??
                (a.data.payload.modified ??
                (a.data.payload.created ?? ad)));
        }
        if (Object.hasOwn(b.data, "payload")) {
            bd = (b.data.payload.published ??
                (b.data.payload.modified ??
                (b.data.payload.created ?? bd)));
        }

        return bd - ad;
    }
    // https://www.11ty.dev/docs/config/#configuration-2
    config.setInputDirectory("src");

    // https://www.11ty.dev/docs/copy/#configuration-api-method
    // Doesnt appear to be relative from the input directory. https://github.com/11ty/eleventy/issues/2043#issuecomment-948826977
    config.addPassthroughCopy("src/css");
    config.addPassthroughCopy("src/img");
    config.addPassthroughCopy("src/svg");
    config.addPassthroughCopy("src/twemoji/svg");
    config.addPassthroughCopy("src/.well-known");
    config.addPassthroughCopy("src/robots.txt");
    config.addPassthroughCopy("src/sitemap.xml");
    https://www.11ty.dev/docs/copy/#emulate-passthrough-copy-during-serve
    config.setServerPassthroughCopyBehavior("passthrough");

    // https://www.11ty.dev/docs/ignores/#configuration-api
    config.ignores.add("@*");
    config.ignores.add("**/copy_me.*");
    config.ignores.delete("src/@skial/*");

    //https://www.11ty.dev/docs/languages/webc/#installation
    config.addPlugin(RenderPlugin);
    config.addPlugin(webc, {
        components: "src/_components/**/*.webc"
    });
    // v4 only
    //config.setHtmlTemplateEngine("webc");

    // https://www.11ty.dev/docs/languages/markdown/
    // https://www.11ty.dev/docs/languages/markdown/#add-your-own-plugins
    // https://github.com/markdown-it/markdown-it#init-with-presets-and-options
    config.amendLibrary("md", (md) => {
        // https://markdown-it.github.io/markdown-it/#MarkdownIt.new
        md = md
            //https://www.11ty.dev/docs/languages/markdown/#optional-amend-the-library-instance
            .set({ html: true, typographer: true, linify: true})
            //https://www.11ty.dev/docs/languages/markdown/#add-your-own-plugins
            .use(md_abbr)
            .use(md_anchor)
            .use(md_attrs)
            .use(md_emoji)
            .use(md_footnote)
            .use((md) => {
                let index = md.block.ruler.__find__('heading');
                let original = md.block.ruler.__rules__[index].fn;
                md.block.ruler.at('heading', function(state, startLine, _endLine, silent) {
                    let result = original(state, startLine, _endLine, silent);
                    let tokens = state.tokens;
                    for (let i = 0; i < tokens.length-2; i++) {
                        let a = tokens[i];
                        let b = tokens[i+1];
                        let c = tokens[i+2];

                        if (a.type == 'heading_open' && a.tag == 'h1' && c.type == 'heading_close') {
                            a.attrSet('slot', 'title');
                            break;
                        }
                    }
                    return result;
                })
            });
        
        // https://github.com/markdown-it/markdown-it-emoji
        md.renderer.rules.emoji = function(token, idx) {
            return twemoji.parse(token[idx].content, { base: "https://haxe.io/twemoji/", folder: "svg", ext: ".svg" });
        }

        return md;
    });

    // https://www.11ty.dev/docs/filters/#asynchronous-filters
    config.addFilter("minus_months", function (date, amount) {
        return DateTime
            .fromJSDate(date)
            .minus( { months: amount })
            .toJSDate();
    })
    config.addFilter("date_lessthan", function (lhs, rhs) {
        return lhs < rhs;
    })

    // https://www.11ty.dev/docs/languages/sass/#configuration
    /**
     * Not as simple as first thought:
     * Read:
     *  - https://danburzo.ro/eleventy-sass/
     *  - https://jkc.codes/blog/using-sass-with-eleventy/
     *  - https://11ty.rocks/posts/process-css-with-lightningcss/
     */
    /*config.addTemplateFormats("scss")
    config.addExtension("scss", {
        outputFileExtension: "css",

		// opt-out of Eleventy Layouts
		useLayouts: false,

		compile: async function (inputContent, inputPath) {
			let parsed = path.parse(inputPath);
			// Don’t compile file names that start with an underscore
			if(parsed.name.startsWith("_")) {
				return;
			}

			let result = sass.compileString(inputContent, {
				loadPaths: [
					parsed.dir || ".",
					this.config.dir.includes,
                    "./node_modules/"
				]
			});

			// Map dependencies for incremental builds
			this.addDependencies(inputPath, result.loadedUrls);

			return async (data) => {
				return result.css;
			};
		},
    });*/

    // https://www.11ty.dev/docs/languages/custom/#get-data-and-get-instance-from-input-path
    // https://rknight.me/blog/adding-cooklang-support-to-eleventy-two-ways/
    config.addExtension("md", {
        key:"md",
        getData: async function (inputPath) {
            let content = await fs.readFile(inputPath, {encoding: "utf8"});
            let md = mdit()
            .use(md_emoji);
            md.renderer.rules.emoji = function(token, idx) {
                return twemoji.parse(token[idx].content, { base: "https://haxe.io/twemoji/", folder: "svg", ext: ".svg" });
            }
            
            var refdef = {};
            var payload = {
                authors: [],
                contributors: []
            };

            let index = md.block.ruler.__find__('reference');
		    let original = md.block.ruler.__rules__[index].fn;
            md.block.ruler.at('reference', function(state, startLine, _endLine, silent) {
                var result = original(state, startLine, _endLine, silent);
                var object = state.env;
                if (object?.references) {
                    // Multiple items
                    if (object.references?.AUTHOR) {
                        let auth = object.references.AUTHOR;
                        if (!payload.authors.some((o) => o == auth.title)) {
                            payload.authors.push( { display: auth.title, url: auth.href }  );
                            delete object.references.AUTHOR;
                        }
                    }

                    if (object.references?._AUTHOR) {
                        let auth = object.references._AUTHOR
                        if (!payload.authors.some((o) => o == auth.title)) {
                            payload.authors.push( { display: auth.title, url: auth.href }  );
                            delete object.references._AUTHOR;
                        }
                    }

                    if (object.references?.CONTRIBUTOR) {
                        let con = object.references.CONTRIBUTOR;
                        if (!payload.contributors.some((o) => o == con.title)) {
                            payload.contributors.push( { display: con.title, url: con.href } );
                            delete object.references.CONTRIBUTOR;
                        }
                        
                    }

                    // Single items
                    if (object.references?.DATE) {
                        let timestamp = DateTime.fromISO(object.references.DATE.title);
                        if (timestamp.isValid) {
                            payload.created = timestamp.toJSDate();
                            
                        } else {
                            let date = DateTime.fromFormat(object.references.DATE.title, 'ccc. LLLL d, yyyy @ t');
                            payload.created = date.toJSDate();
                            
                        }
                        delete object.references.DATE;
                        
                    }

                    if (object.references?.MODIFIED) {
                        let date = new Date();
                        let timestamp = Date.parse(object.references.MODIFIED.title);
                        if (!Number.isNaN(timestamp)) {
                            date.setTime(timestamp);
                            payload.modified = date;
                        }
                        delete object.references.MODIFIED;
                        
                    }

                    if (object.references?.PUBLISHED) {
                        let date = new Date();
                        let timestamp = Date.parse(object.references.PUBLISHED.title);
                        if (!Number.isNaN(timestamp)) {
                            date.setTime(timestamp);
                            payload.published = date;
                        }
                        delete object.references.PUBLISHED;
                        
                    }

                    if (object.references?.DESCRIPTION) {
                        payload.description = object.references.DESCRIPTION.title;
                        delete object.references.DESCRIPTION;
                        
                    }
                }

                return result;
            });
            let tokens = md.parse(content.toString(), refdef);
            for (let i = 0; i < tokens.length-2; i++) {
                let a = tokens[i];
                let b = tokens[i+1];
                let c = tokens[i+2];

                if (a.type == 'heading_open' && a.tag == 'h1' && c.type == 'heading_close') {
                    payload.title = md.renderInline(b.content.replace(/<br\/>/,':'));
                    break;
                }
            }

            // Use package.json author details if no author was specified.
            var extra = {};
            if (payload.authors.length == 0) {
                // https://www.11ty.dev/docs/data-computed/#using-a-template-string
                extra = {
                    eleventyComputed: {
                        payload: {
                            authors: [{
                                display: "{{ pkg.author.name }}", 
                                url: "{{ pkg.author.url }}"
                            }]
                        }
                    }
                };
            }
            // Overwrite titles for roundups & older content
            if (!Object.hasOwn(payload, "title") && inputPath.indexOf('/roundups') > -1) {
                extra.eleventyComputed.payload.title = "Haxe Roundup {{ page.fileSlug }}";

                if (inputPath.indexOf('/wwx/') > -1) {
                    extra.eleventyComputed = extra.eleventyComputed || {};
                    extra.eleventyComputed.payload = extra.eleventyComputed.payload || {};
                    extra.eleventyComputed.payload.title = "WWX {{ page.fileSlug }} Roundup";
                    extra.eleventyComputed.date = "{{ page.fileSlug }}";
                }

            }

            if (inputPath.indexOf('src/wwx/') > -1) {
                let parts = inputPath.split('/');
                let year = parts.filter((str) => !Number.isNaN(Number.parseInt(str)));
                
                if (year.length > 0) {
                    extra.eleventyComputed = extra.eleventyComputed || {};
                    extra.eleventyComputed.payload = extra.eleventyComputed.payload || {};
                    extra.eleventyComputed.payload.title = "WWX " + year[0] + " Developer Interview: {{ page.fileSlug }}";

                    if (!payload?.published) payload.published = new Date(year);
                    if (!payload?.modified) payload.modified = new Date(year);
                    if (!payload?.created) payload.created = new Date(year);
                }
            }
            //console.log(payload);
            return { ...refdef, payload:payload, ...extra };
        }
    });

    // https://www.11ty.dev/docs/collections-api/#example-get-all-sort
    // https://www.11ty.dev/docs/collections/#collection-item-data-structure
    config.addCollection("roundups", async (collections) => {
        let roundups = collections.getFilteredByTag("roundups");
        roundups = roundups.filter(function(r) {
            return r.data.tags.length == 1 && r.data.tags[0] == "roundups";
        })
        roundups = roundups.sort( function(a, b) {
            let an = Number.parseInt(a.page.fileSlug);
            let bn = Number.parseInt(b.page.fileSlug);

            if (Number.isNaN(an)) {
                an = 0;
            }
            if (Number.isNaN(bn)) {
                bn = 0;
            }

            return bn - an;
        });
        
        return roundups;
        
    });
    config.addCollection("wwx", async (collections) => {
        let wwx = collections.getFilteredByTag("wwx");
        wwx = wwx.filter( function(a) {
            if (a.data?.tags && a.data.tags.length == 1) return a.data.tags[0] != "roundups";
            return true;
        })
        wwx = wwx.sort( dateSort );
        return wwx;
    });
    ["gamejam", "releases", "videos", "blog"].forEach( function(tag) {
        config.addCollection(tag, async (collections) => {
            return collections.getFilteredByTag(tag).sort( dateSort );
        });
    } );
}