// MADE BY MIGUVT, MADE FOR LINUX, SHOULD BE WINDOWS COMPATIBLE BUT NOT TESTED

package main

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

const defaultPlaceholder = `<UUID_PLACEHOLDER_\w{4}>`

func main() {
	var (
		inPath        string
		outPath       string
		placeholder   string
		inPlace       bool
		perMatchUUID  bool
		force         bool
		dryRun        bool
		failIfNoMatch bool
		literalMode   bool
	)

	flag.StringVar(&inPath, "in", "", "Input file path (required)")
	flag.StringVar(&outPath, "out", "", "Output file path (optional). If empty, writes next to input with -UUID-REPLACED suffix.")
	flag.StringVar(&placeholder, "placeholder", defaultPlaceholder, "Placeholder pattern to replace (regex by default, use -literal for exact text match)")
	flag.BoolVar(&inPlace, "in-place", false, "Overwrite the input file (atomic temp file + rename)")
	flag.BoolVar(&perMatchUUID, "per-match", false, "Generate a new UUID for each placeholder match (default: one UUID for all replacements)")
	flag.BoolVar(&force, "force", false, "Allow overwriting an existing output file")
	flag.BoolVar(&dryRun, "dry-run", false, "Do not write output; just report what would change")
	flag.BoolVar(&failIfNoMatch, "fail-if-no-match", false, "Exit with error if no placeholder was found")
	flag.BoolVar(&literalMode, "literal", false, "Treat placeholder as literal text instead of regex pattern")

	flag.Usage = func() {
		_, _ = fmt.Fprintf(flag.CommandLine.Output(),
			"uuid-replacer replaces placeholders with UUIDs.\n\nUsage:\n  uuid-replacer -in /path/to/file [flags]\n\nFlags:\n")
		flag.PrintDefaults()
	}
	flag.Parse()

	if strings.TrimSpace(inPath) == "" {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(inPath, outPath, placeholder, inPlace, perMatchUUID, force, dryRun, failIfNoMatch, literalMode); err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func run(inPath, outPath, placeholder string, inPlace, perMatch, force, dryRun, failIfNoMatch, literalMode bool) error {
	data, err := os.ReadFile(inPath)
	if err != nil {
		return fmt.Errorf("read input: %w", err)
	}
	if placeholder == "" {
		return errors.New("placeholder cannot be empty")
	}

	// Compile regex pattern - escape if literal mode
	var re *regexp.Regexp
	if literalMode {
		re = regexp.MustCompile(regexp.QuoteMeta(placeholder))
	} else {
		re, err = regexp.Compile(placeholder)
		if err != nil {
			return fmt.Errorf("invalid regex pattern: %w", err)
		}
	}

	matches := len(re.FindAllIndex(data, -1))
	if matches == 0 && failIfNoMatch {
		return fmt.Errorf("no matches for placeholder %q", placeholder)
	}

	var replaced []byte
	if perMatch {
		var replErr error
		replaced = re.ReplaceAllFunc(data, func(_ []byte) []byte {
			if replErr != nil {
				return nil
			}
			u, err := newUUIDv4()
			if err != nil {
				replErr = err
				return nil
			}
			return []byte(u)
		})
		if replErr != nil {
			return fmt.Errorf("uuid: %w", replErr)
		}
	} else {
		u, err := newUUIDv4()
		if err != nil {
			return fmt.Errorf("uuid: %w", err)
		}
		replaced = re.ReplaceAllLiteral(data, []byte(u))
	}

	finalOut := outPath
	if inPlace {
		finalOut = inPath
	} else if strings.TrimSpace(finalOut) == "" {
		finalOut = defaultOutputPath(inPath)
	}

	changed := !bytes.Equal(data, replaced)
	_, _ = fmt.Fprintf(os.Stdout, "Matches: %d\nChanged: %t\n", matches, changed)

	if dryRun {
		_, _ = fmt.Fprintf(os.Stdout, "Dry-run: would write %s\n", finalOut)
		return nil
	}

	if !force && !inPlace {
		if _, err := os.Stat(finalOut); err == nil {
			return fmt.Errorf("output file exists: %s (use -force to overwrite)", finalOut)
		} else if !os.IsNotExist(err) {
			return fmt.Errorf("check output path: %w", err)
		}
	}

	if err := writeFileAtomic(finalOut, replaced, 0o644, force || inPlace); err != nil {
		return fmt.Errorf("write output: %w", err)
	}

	_, _ = fmt.Fprintf(os.Stdout, "Wrote: %s\n", finalOut)
	return nil
}

func defaultOutputPath(inPath string) string {
	dir := filepath.Dir(inPath)
	base := filepath.Base(inPath)
	ext := filepath.Ext(base)
	name := strings.TrimSuffix(base, ext)
	return filepath.Join(dir, name+"-UUID-REPLACED"+ext)
}

func writeFileAtomic(path string, data []byte, perm os.FileMode, overwrite bool) error {
	dir := filepath.Dir(path)
	tmp, err := os.CreateTemp(dir, ".uuid-replacer-*")
	if err != nil {
		return err
	}
	tmpName := tmp.Name()
	defer func() {
		_ = tmp.Close()
		_ = os.Remove(tmpName)
	}()

	if err := tmp.Chmod(perm); err != nil {
		return err
	}
	if _, err := tmp.Write(data); err != nil {
		return err
	}
	if err := tmp.Sync(); err != nil {
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}

	if overwrite {
		_ = os.Remove(path)
	}

	return os.Rename(tmpName, path)
}

func newUUIDv4() (string, error) {
	var b [16]byte
	if _, err := io.ReadFull(rand.Reader, b[:]); err != nil {
		return "", err
	}
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80

	hexs := hex.EncodeToString(b[:])
	return hexs[0:8] + "-" + hexs[8:12] + "-" + hexs[12:16] + "-" + hexs[16:20] + "-" + hexs[20:32], nil
}
