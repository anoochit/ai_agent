# Remove all files in the build directory
rm -rf build/*

# Combine full book for epub
echo "EPUB input"

touch build/epub_input.md
for f in chapters/*.md; do
  echo "Processing $f"
  echo "" >> build/epub_input.md
  cat "$f" >> build/epub_input.md
  echo "" >> build/epub_input.md
done

