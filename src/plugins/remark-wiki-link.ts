import { visit } from "unist-util-visit";
import type { Plugin } from "unified";
import type { Root, Text, Link } from "mdast";
import fs from "node:fs";
import path from "node:path";

/**
 * Build a set of known slugs for a content collection directory.
 * Scans recursively for .md files and returns their relative paths without extension.
 */
function buildSlugSet(contentDir: string): Set<string> {
  const slugs = new Set<string>();
  if (!fs.existsSync(contentDir)) return slugs;

  function walk(dir: string, prefix: string) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        walk(path.join(dir, entry.name), `${prefix}${entry.name}/`);
      } else if (entry.name.endsWith(".md")) {
        const slug = `${prefix}${entry.name.replace(/\.md$/, "")}`;
        slugs.add(slug);
      }
    }
  }
  walk(contentDir, "");
  return slugs;
}

// Resolve slug sets once at build time (public collections only — never link to private data)
const contentBase = path.resolve(
  new URL(import.meta.url).pathname,
  "../../content",
);
const notesSlugs = buildSlugSet(path.join(contentBase, "notes"));
const memosSlugs = buildSlugSet(path.join(contentBase, "memos"));

/**
 * Custom remark plugin to convert Obsidian-style wiki-links [[target]] and [[target|alias]]
 * into standard Markdown links. Also handles embeds ![[image.ext]].
 *
 * Link resolution order:
 *   1. notes collection (public)
 *   2. memos collection (public)
 * Private data (idea, project, contracts) is never linked.
 */
const remarkWikiLink: Plugin<[], Root> = () => {
  return (tree: Root) => {
    visit(tree, "text", (node: Text, index, parent) => {
      if (!parent || index === undefined) return;

      const value = node.value;
      // Match ![[...]] (embeds) and [[...]] (links)
      const wikiLinkRegex = /(!?\[\[([^\]]+)\]\])/g;
      const parts: (Text | Link | any)[] = [];
      let lastIndex = 0;
      let match: RegExpExecArray | null;

      while ((match = wikiLinkRegex.exec(value)) !== null) {
        const fullMatch = match[0];
        const inner = match[2];
        const isEmbed = fullMatch.startsWith("!");
        const matchStart = match.index;

        // Text before the match
        if (matchStart > lastIndex) {
          parts.push({
            type: "text",
            value: value.slice(lastIndex, matchStart),
          });
        }

        if (isEmbed) {
          // Image embed: ![[filename.ext]]
          const imgExtensions = [
            ".png",
            ".jpg",
            ".jpeg",
            ".gif",
            ".svg",
            ".webp",
            ".bmp",
          ];
          const isImage = imgExtensions.some((ext) =>
            inner.toLowerCase().endsWith(ext),
          );
          if (isImage) {
            parts.push({
              type: "image",
              url: `/images/memos/${encodeURIComponent(inner)}`,
              alt: inner,
            });
          } else {
            // Non-image embed, keep as text
            parts.push({ type: "text", value: fullMatch });
          }
        } else {
          // Wiki link: [[target]] or [[target|alias]]
          const pipeIndex = inner.indexOf("|");
          let target: string;
          let alias: string;
          if (pipeIndex !== -1) {
            target = inner.slice(0, pipeIndex).trim();
            alias = inner.slice(pipeIndex + 1).trim();
          } else {
            target = inner.trim();
            alias = target;
          }

          // Strip heading anchors for URL
          const hashIndex = target.indexOf("#");
          const slug = hashIndex !== -1 ? target.slice(0, hashIndex) : target;
          const heading = hashIndex !== -1 ? target.slice(hashIndex) : "";

          // Resolve to the correct public collection
          // Check by title match against known slugs (slug may include subdirectory)
          let collection = "notes"; // default
          const matchesNotes = [...notesSlugs].some(
            (s) => s === slug || s.endsWith(`/${slug}`),
          );
          const matchesMemos = [...memosSlugs].some(
            (s) => s === slug || s.endsWith(`/${slug}`),
          );

          if (matchesNotes) {
            collection = "notes";
          } else if (matchesMemos) {
            collection = "memos";
          }
          // If neither matches, default to /notes/ (graceful fallback)

          const url = `/${collection}/${encodeURIComponent(slug)}${heading}`;

          parts.push({
            type: "link",
            url,
            children: [{ type: "text", value: alias }],
          });
        }

        lastIndex = matchStart + fullMatch.length;
      }

      // Remaining text after last match
      if (lastIndex < value.length) {
        parts.push({ type: "text", value: value.slice(lastIndex) });
      }

      if (parts.length > 0 && lastIndex > 0) {
        parent.children.splice(index, 1, ...parts);
      }
    });
  };
};

export default remarkWikiLink;
