"""
Script for converting old LUT shaders into the new format.
"""

import sys, os, re

PROCESSED_FILES_OUTPUT_PATH = "./Shaders"
NAME_REGEX = re.compile(r"technique\s+(\S+)")
LUT_LIST_REGEX = re.compile(r"ui_items\s*=\s*(.*)\s*;")
TEXTURE_NAME_REGEX = re.compile(r"#define\s+fLUT_TextureName\s+(.*)")
TILE_SIZE_XY = re.compile(r"#define\s+fLUT_TileSizeXY\s+(.*)")
TILE_AMOUNT = re.compile(r"#define\s+fLUT_TileAmount\s+(.*)")
LUT_AMOUNT = re.compile(r"#define\s+fLUT_LutAmount\s+(.*)")

class ProcessFileError(RuntimeError):
	def __init__(self, message, path):
		super().__init__(message)
		self.path = path

def main(args):
	if len(args) < 2:
		print("Expected paths of files to process", file=sys.stderr)
		return 1

	try:
		if not os.path.isdir(PROCESSED_FILES_OUTPUT_PATH):
			os.makedirs(PROCESSED_FILES_OUTPUT_PATH)

		# Process all the arguments except the first as file paths.
		for path in args[1:]:
			process_file(path)

		return 0
	except ProcessFileError as e:
		print(f"Fatal error in file {e.path}:\n{e}\n", file=sys.stderr)
	except BaseException as e:
		print(f"Fatal error:\n{e}", file=sys.stderr)

def process_file(path):
	name = os.path.basename(path)
	output_path = f"{PROCESSED_FILES_OUTPUT_PATH}/{name}"

	with open(path, "r") as input, open(output_path, "w") as output:
		in_txt = input.read()
		out_lines = []

		try:
			name = find_keyword(in_txt, NAME_REGEX)
			out_lines.append(f"#define fLUT_Name {name}")

			lut_list = find_keyword(in_txt, LUT_LIST_REGEX)
			out_lines.append(f"#define fLUT_LutList {lut_list}")

			texture_name = find_keyword(in_txt, TEXTURE_NAME_REGEX)
			out_lines.append(f"#define fLUT_TextureName {texture_name}")

			tile_size_xy = find_keyword(in_txt, TILE_SIZE_XY)
			out_lines.append(f"#define fLUT_TileSizeXY {tile_size_xy}")

			tile_amount = find_keyword(in_txt, TILE_AMOUNT)
			out_lines.append(f"#define fLUT_TileAmount {tile_amount}")

			lut_amount = find_keyword(in_txt, LUT_AMOUNT)
			out_lines.append(f"#define fLUT_LutAmount {lut_amount}")

			out_lines.append(f"#include \"_BaseLUT.fxh\"")

			for line in out_lines:
				output.write(f"{line}\n")
		except BaseException as e:
			raise ProcessFileError(str(e), path)

def find_keyword(txt, pattern):
	if isinstance(pattern, str):
		pattern = re.compile(pattern)

	match = pattern.findall(txt)
	if not match:
		raise RuntimeError(f"Failed to find pattern \"{pattern.pattern}\"")

	return match[0]

if __name__ == "__main__":
	sys.exit(main(sys.argv) or 0)
