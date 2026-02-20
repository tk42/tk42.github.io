import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import remarkMath from "remark-math";
import rehypeKatex from "rehype-katex";
import remarkWikiLink from "./src/plugins/remark-wiki-link";

export default defineConfig({
  site: "https://tk42.jp",
  output: "static",
  integrations: [sitemap()],
  markdown: {
    remarkPlugins: [remarkMath, remarkWikiLink],
    rehypePlugins: [[rehypeKatex, { strict: false }]],
  },
});
