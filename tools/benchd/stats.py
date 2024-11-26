from argparse import ArgumentParser
from pathlib import Path


def main():
    parser = ArgumentParser()
    parser.add_argument("dir", type=str)
    args = parser.parse_args()

    work_dir = Path(args.dir)
    # iterate all files in work_dir / monitor, iterate by file name order, each file name is a int
    for file in sorted(work_dir.glob("monitor/*"), key=lambda x: int(x.stem)):
        # print file name
        if file.stem == "5":
            continue
        content = file.read_text()
        # get the second line
        second_line = content.split("\n")[1]
        trigger_time = int(second_line.split(",")[1])
        if trigger_time != 0:
            print(file.stem, trigger_time)
            break


if __name__ == "__main__":
    main()
