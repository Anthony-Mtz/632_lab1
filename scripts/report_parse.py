import argparse

def print_dict(d, list, key):
    for item in list:
        if item in d[key]:
            print(f"{d[key][item]}", end=" ")
        else:
            print("x", end=" ")

def main(args):
    f = open(args.filename, 'r')
    flag = False
    test_suite = {}
    test_names = ["Frequency", "BlockFrequency", "CumulativeSums", "Runs", 
                  "LongestRun", "Rank", "FFT", "NonOverlappingTemplate", "OverlappingTemplate", 
                  "Universal", "ApproximateEntropy", "RandomExcursions", "RandomExcursionsVariant", 
                  "Serial", "LinearComplexity"]
    
    test_suite["Streams Passed"] = {}
    test_suite["Streams Run"] = {}
    test_suite["P Value"] = {}

    for line in f:
        if flag and not("\n" == line):
            l = line.split()
            test_suite["Streams Passed"][f"{l[4]}"] = l[2][:l[2].find('/')]
            test_suite["Streams Run"][f"{l[4]}"] = l[2][l[2].find('/') + 1:]
            test_suite["P Value"][f"{l[4]}"] = l[0]
        if "Final" in line:
            flag = True

    for key in test_suite:
        print_dict(test_suite, test_names, key)
    print("\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run File Parser")
    parser.add_argument("-f", "--filename")
    main(parser.parse_args())