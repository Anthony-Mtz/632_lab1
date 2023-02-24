import os
import matplotlib.pyplot as plt

# # 
# def convert_to_float(frac_str):
#     try:
#         return float(frac_str)
#     except ValueError:
#         num, denom = frac_str.split('/')
#         try:
#             leading, num = num.split(' ')
#             whole = float(leading)
#         except ValueError:
#             whole = 0
#         frac = float(num) / float(denom)
#         return whole - frac if whole < 0 else whole + frac

# # check ranges and naming convention
# slow_range = range(0, 2) # 0 to 9 inclusive - sampled 5
# fast_range = range(0, 2) # 0 to 15 inclusive - source  8
# test_range = range(15)

# # initialize p-values array
# pvalues = [[["" for k in fast_range] for j in slow_range] for i in test_range]

# # initialize p-value pass/fail array
# pvalues_pf = [[["" for k in fast_range] for j in slow_range] for i in test_range]

# # initialize proportion array
# proportions = [[["" for k in fast_range] for j in slow_range] for i in test_range]

# # initialize proportion pass/fail array
# proportions_pf = [[["" for k in fast_range] for j in slow_range] for i in test_range]

# # initialize temporary data arrays for parsing purposes
# data = [[["" for k in range(188)] for j in fast_range] for i in slow_range]
# parsed_data = [[["" for k in test_range] for j in fast_range] for i in slow_range]

# for slow_idx in slow_range:
#     for fast_idx in fast_range:
#         directory = f"../results/unused{str(slow_idx)}-{str(fast_idx)}/"
#         # directory = f"../results/AlgorithmTesting{str(slow_idx)}-{str(fast_idx)}/"
#         print(directory)
#         filename = os.path.join(directory, "finalAnalysisReport.txt")
#         print(filename)

#         # Initial averages and counters for tests with multiple lines
#         cumulativesums_pvalue_avg = 0
#         cumulativesums_proportion_avg = 0
#         cumulativesums_count = 0

#         nonoverlapping_pvalue_avg = 0
#         nonoverlapping_proportion_avg = 0
#         nonoverlapping_count = 0

#         randomexcursions_pvalue_avg = 0
#         randomexcursions_proportion_avg = 0
#         randomexcursions_count = 0

#         randomexcursionsvariant_pvalue_avg = 0
#         randomexcursionsvariant_proportion_avg = 0
#         randomexcursionsvariant_count = 0

#         serial_pvalue_avg = 0
#         serial_proportion_avg = 0
#         serial_count = 0

#         parsed_num_idx = -1

#         file = open(filename, "r")
#         for line_num in range(195):
#             line = file.readline()
#             if line == "":
#                 break
#             if (line_num < 7):
#                 continue
#             else:
#                 num_idx = line_num-7
#                 print(num_idx)
#                 splitted_line = " ".join(line.split())
#                 splitted_list = splitted_line.split()

#                 # case on if how many * are in the line
#                 asterisk_count = splitted_line.count("*")
#                 if asterisk_count == 0:
#                     data[slow_idx][fast_idx][num_idx] = splitted_list[-3:]
#                 elif asterisk_count == 1:
#                     data[slow_idx][fast_idx][num_idx] = splitted_list[-4:]
#                 elif asterisk_count == 2:
#                     data[slow_idx][fast_idx][num_idx] = splitted_list[-5:]

#                 current_line = data[slow_idx][fast_idx][num_idx]

#                 # Make every line into an array of 5 elements
#                 if len(data[slow_idx][fast_idx][num_idx]) == 3:
#                     data[slow_idx][fast_idx][num_idx].insert(1, ' ')
#                     data[slow_idx][fast_idx][num_idx].insert(3, ' ')
#                 elif len(data[slow_idx][fast_idx][num_idx]) == 4:
#                     print("HERE")
#                     print(data[slow_idx][fast_idx][num_idx])
#                     if data[slow_idx][fast_idx][num_idx][1] == "*":
#                         data[slow_idx][fast_idx][num_idx].insert(3, ' ')
#                     elif data[slow_idx][fast_idx][num_idx][2] == "*":
#                         data[slow_idx][fast_idx][num_idx].insert(1, ' ')

#                 # CumulativeSums
#                 if (num_idx == 2) or (num_idx == 3): 
#                     cumulativesums_pvalue_avg += float(data[slow_idx][fast_idx][num_idx][0])
#                     cumulativesums_proportion_avg += convert_to_float(data[slow_idx][fast_idx][num_idx][2])
#                     cumulativesums_count += 1
#                     parsed_num_idx = 2 # 3rd test

#                 # NonOverlapping
#                 elif (num_idx >= 8) and (num_idx <= 155): 
#                     print(data[slow_idx][fast_idx][num_idx])
#                     nonoverlapping_pvalue_avg += float(data[slow_idx][fast_idx][num_idx][0])
#                     nonoverlapping_proportion_avg += convert_to_float(data[slow_idx][fast_idx][num_idx][2])
#                     nonoverlapping_count += 1
#                     parsed_num_idx = 7 # 8th test

#                 # RandomExcursions
#                 elif (num_idx >= 159) and (num_idx <= 166): 
#                     if(data[slow_idx][fast_idx][num_idx][0] == '----'):
#                         randomexcursions_pvalue_avg += 0
#                         data[slow_idx][fast_idx][num_idx][1] = '*'
#                     if(data[slow_idx][fast_idx][num_idx][2] == '------'):
#                         randomexcursions_proportion_avg += 0
#                         data[slow_idx][fast_idx][num_idx][3] = '*'
#                     randomexcursions_count += 1
#                     parsed_num_idx = 11 # 12th test

#                 # RandomExcursionsVariant
#                 elif (num_idx >= 167) and (num_idx <= 184): 
#                     if(data[slow_idx][fast_idx][num_idx][0] == '----'):
#                         randomexcursionsvariant_pvalue_avg += 0
#                         data[slow_idx][fast_idx][num_idx][1] = '*'
#                     if(data[slow_idx][fast_idx][num_idx][2] == '------'):
#                         randomexcursionsvariant_proportion_avg += 0
#                         data[slow_idx][fast_idx][num_idx][3] = '*'
#                     randomexcursionsvariant_count += 1
#                     parsed_num_idx = 12 # 13th test

#                 # Serial
#                 elif (num_idx == 185) or (num_idx == 186):
#                     serial_pvalue_avg += float(data[slow_idx][fast_idx][num_idx][0])
#                     serial_proportion_avg += convert_to_float(data[slow_idx][fast_idx][num_idx][2])
#                     serial_count += 1
#                     parsed_num_idx = 13 # 14th test

#                 else:
#                     parsed_num_idx += 1
#                     data[slow_idx][fast_idx][num_idx][2] = convert_to_float(data[slow_idx][fast_idx][num_idx][2])
#                     parsed_data[slow_idx][fast_idx][parsed_num_idx] = data[slow_idx][fast_idx][num_idx]

#                     print(parsed_num_idx)

#         # Add CumulativeSums to Parsed Data
#         cumulativesums_pvalue_avg /= cumulativesums_count
#         cumulativesums_proportion_avg /= cumulativesums_count
#         parsed_data[slow_idx][fast_idx][2] = [cumulativesums_pvalue_avg, '*', cumulativesums_proportion_avg, '*', 'CumulativeSums']
#         if (cumulativesums_pvalue_avg >= 0.01):
#             parsed_data[slow_idx][fast_idx][2][1] = ' '
#         if (cumulativesums_proportion_avg >=8):
#             parsed_data[slow_idx][fast_idx][2][3] = ' '

#         # Add NonOverlappingTemplate to Parsed Data
#         nonoverlapping_pvalue_avg /= nonoverlapping_count
#         nonoverlapping_proportion_avg /= nonoverlapping_count
#         parsed_data[slow_idx][fast_idx][7] = [nonoverlapping_pvalue_avg, '*', nonoverlapping_proportion_avg, '*', 'NonOverlappingTemplate']
#         if (nonoverlapping_pvalue_avg >= 0.01):
#             parsed_data[slow_idx][fast_idx][7][1] = ' '
#         if (nonoverlapping_proportion_avg >=8):
#             parsed_data[slow_idx][fast_idx][7][3] = ' '

#         # Add RandomExcursions to Parsed Data
#         randomexcursions_pvalue_avg /= randomexcursions_count
#         randomexcursions_proportion_avg /= randomexcursions_count
#         parsed_data[slow_idx][fast_idx][11] = [randomexcursions_pvalue_avg, '*', randomexcursions_proportion_avg, '*', 'RandomExcursions']
#         if (randomexcursions_pvalue_avg >= 0.01):
#             parsed_data[slow_idx][fast_idx][11][1] = ' '
#         if (randomexcursions_proportion_avg >=8):
#             parsed_data[slow_idx][fast_idx][11][3] = ' '

#         # Add RandomExcursionsVariant to Parsed Data
#         randomexcursionsvariant_pvalue_avg /= randomexcursionsvariant_count
#         randomexcursionsvariant_proportion_avg /= randomexcursionsvariant_count
#         parsed_data[slow_idx][fast_idx][12] = [randomexcursionsvariant_pvalue_avg, '*', randomexcursionsvariant_proportion_avg, '*', 'RandomExcursionsVariant']
#         if (randomexcursionsvariant_pvalue_avg >= 0.01):
#             parsed_data[slow_idx][fast_idx][12][1] = ' '
#         if (randomexcursionsvariant_proportion_avg >=8):
#             parsed_data[slow_idx][fast_idx][12][3] = ' '

#         # Add Serial to Parsed Data
#         serial_pvalue_avg /= serial_count
#         serial_proportion_avg /= serial_count
#         parsed_data[slow_idx][fast_idx][13] = [serial_pvalue_avg, '*', serial_proportion_avg, '*', 'Serial']
#         if (serial_pvalue_avg >= 0.01):
#             parsed_data[slow_idx][fast_idx][13][1] = ' '
#         if (serial_proportion_avg >=8):
#             parsed_data[slow_idx][fast_idx][13][3] = ' '

#         print(parsed_data[slow_idx][fast_idx])

#         file.close()

# print(parsed_data)

# test_names = ["" for i in test_range]

# for slow_idx in slow_range:
#     for fast_idx in fast_range:
#         for test_idx in test_range:
#             pvalues[test_idx][slow_idx][fast_idx] = parsed_data[slow_idx][fast_idx][test_idx][0]
#             pvalues_pf[test_idx][slow_idx][fast_idx] = parsed_data[slow_idx][fast_idx][test_idx][1]
#             proportions[test_idx][slow_idx][fast_idx] = parsed_data[slow_idx][fast_idx][test_idx][2]
#             proportions_pf[test_idx][slow_idx][fast_idx] = parsed_data[slow_idx][fast_idx][test_idx][3]
#             test_names[test_idx] = parsed_data[slow_idx][fast_idx][test_idx][4]
#             if pvalues_pf[test_idx][slow_idx][fast_idx] == ' ':
#                 pvalues_pf[test_idx][slow_idx][fast_idx] = True
#             elif pvalues_pf[test_idx][slow_idx][fast_idx] == '*': 
#                 pvalues_pf[test_idx][slow_idx][fast_idx] = False
#             if proportions_pf[test_idx][slow_idx][fast_idx] == ' ':
#                 proportions_pf[test_idx][slow_idx][fast_idx] = True
#             elif proportions_pf[test_idx][slow_idx][fast_idx] == '*':
#                 proportions_pf[test_idx][slow_idx][fast_idx] = False

# print(pvalues)
# print(pvalues_pf)
# print(proportions)
# print(proportions_pf)
# print(test_names)

# # TODO: fill in source frequencies

# source_frequency_list = []

# num_inverters_list = [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67]
# num_inverters_list = [7, 11]

# # pvalue plots - total 15 plots for all 15 tests

# # keep slow_idx same = ratio is same



# Matplotlib
# for test_idx in test_range:
#     title = test_names[test_idx]
#     plt.figure(1)
#     for slow_idx in slow_range:
#         ratio = (slow_idx+1)*5
#         pvalue_data = [0 for i in fast_range]
#         legend_label = str(ratio)+ "x"
#         for fast_idx in fast_range:
#             pvalue_data[fast_idx] = float(pvalues[test_idx][slow_idx][fast_idx])
#             print(type(pvalue_data[fast_idx]))
#         print(len(pvalue_data))
#         plt.plot(num_inverters_list, pvalue_data, label = legend_label) #, linestyle="-")
#     plt.title(title)
#     plt.legend()
#     plt.xlabel('Num of Inverters')
#     plt.ylabel('P-value')
#     plot_path = '../results/figures/pvalues/' + title + '.pdf'
#     plt.savefig(plot_path)
#     plt.close(1)

# # Plotly alternative - doesn't work right now
# pvalues_df = pd.DataFrame(pvalues)
# for test_idx in test_range:
#     fig = px.line(pvalues_df, x=num_inverters_list, y=pvalues_df[test_idx][0])
#     for slow_idx in slow_range:
#         fig = px.line(pvalues_df, x=num_inverters_list, y=pvalues_df[test_idx][slow_idx-1])
#     fig.show()

# Shmoo plots - total 15x2 = 30 plots


''' start here'''

outpath = 'shmoo/'
tests = ['Frequency', 'BlockFrequency', 'CumulativeSums', 'Runs', 'LongestRun', 'Rank', 'FFT', 'NonOverlappingTemplate', 'OverlappingTemplate', 'Universal', 'ApproximateEntropy', 'RandomExcursions', 'RandomExcursionsVariant', 'Serial', 'LinearComplexity']
# oscillator_freq = [33.12660483, 37.81016997, 42.27151541, 52.53969266, 61.42779535, 73.837768, 79.14086704, 100.7158384, 122.854474, 137.920189, 182.3029244, 216.8933962, 347.0505685]
oscillator_freq = [1,2,3,4,5,6,7,8,9,10,11,12,13]
# avg_percent_sample_freq = [1.28, 2.32, 4.37, 8.54, 19.07]
avg_percent_sample_freq = [1,2,3,4,5]

# pass fail data
test_pass_rate = [[[-1,1,1,1,1],[-1,1,1,1,1],[-1,1,1,1,1],[1,1,1,0.9,0.9],[1,-1,0.9,1,1],[1,1,1,1,1],[1,.6,1,1,1],[1,-1,1,0.9,1],[1,1,1,1,1],[1,.8,1,0.9,1],[1,1,1,1,1],[1,.9,0.8,1,1],[1,1,1,1,0.9]]]
PF_data = [[[None]*len(avg_percent_sample_freq)] * len(oscillator_freq)] * len(tests)


# for test_idx, test in enumerate(tests):
#     for i in range(len(oscillator_freq)):
#         for j in range(len(avg_percent_sample_freq)):
#             PF_data[test_idx][j][j] = True if () else False

for oscil_idx in range(len(oscillator_freq)):
    for sample_idx in range(len(avg_percent_sample_freq)):
        PF_data[0][oscil_idx][sample_idx] = True if (test_pass_rate[0][oscil_idx][sample_idx]) else False



for test_idx, test in enumerate(tests):
    shmoo_pvalue_title = test + " Shmoo Plot"

    shmoo_rbg = [[[0.0 for k in range(3)] for j in oscillator_freq] for i in avg_percent_sample_freq]
    # print(shmoo_rbg)

    for sample_idx in range(len(avg_percent_sample_freq)):
        for oscil_idx in range(len(oscillator_freq)):
            if PF_data[test_idx][oscil_idx][sample_idx] == True: # Pass = Green
                shmoo_rbg[sample_idx][oscil_idx][1] = 1.0

            elif PF_data[test_idx][oscil_idx][sample_idx] == False: # Fail = Red
                shmoo_rbg[sample_idx][oscil_idx][0] = 1.0
    

    plt.figure(1)
    plt.imshow(shmoo_rbg)
    plt.title(shmoo_pvalue_title)
    plt.xlabel('Oscillator Freq')
    plt.ylabel('Average sample freq (as percentage of oscillator freq)')
    plt.xticks(avg_percent_sample_freq)
    plt.yticks(oscillator_freq)
    plot_path = os.path.join(outpath, test+".png")
    plt.savefig(plot_path)
    plt.close(2)

    exit()


''' end here'''

# ratio_diff = range(5, 5, 55)

# # Matplotlib
# for test_idx in test_range:
#     title = test_names[test_idx]
#     shmoo_pvalue_title = title + " P-value Shmoo Plot"
#     shmoo_proportion_title = title + " Proportion Shmoo Plot"
#     pvalue_rbg = [[[0.0 for k in range(3)] for j in fast_range] for i in slow_range]
#     proportions_rbg = [[[0.0 for k in range(3)] for j in fast_range] for i in slow_range]
#     for slow_idx in slow_range:
#         for fast_idx in fast_range:
#             if pvalues_pf[test_idx][slow_idx][fast_idx] == True: # Pass = Green
#                 pvalue_rbg[slow_idx][fast_idx][1] = 1.0
#             elif pvalues_pf[test_idx][slow_idx][fast_idx] == False: # Fail = Red
#                 pvalue_rbg[slow_idx][fast_idx][0] = 1.0

#             if proportions_pf[test_idx][slow_idx][fast_idx] == True: # Pass = Green
#                 proportions_rbg[slow_idx][fast_idx][1] = 1.0
#             elif proportions_pf[test_idx][slow_idx][fast_idx] == False: # Fail = Red
#                 proportions_rbg[slow_idx][fast_idx][0] = 1.0
    
#     print(pvalue_rbg)
#     plt.figure(2)
#     plt.imshow(pvalue_rbg)
#     plt.title(shmoo_pvalue_title)
#     plt.xlabel('Source Frequency')
#     plt.ylabel('Sample to Source Frequency Ratio')
#     plt.xticks(fast_range)
#     plt.yticks(slow_range)
#     pvalue_plot_path = '../results/figures/shmoo/pvalues/' + shmoo_pvalue_title + '.pdf'
#     plt.savefig(pvalue_plot_path)
#     plt.close(2)

#     print(proportions_rbg)
#     plt.figure(3)
#     plt.imshow(proportions_rbg)
#     plt.title(shmoo_proportion_title)
#     # plt.axis('on')
#     plt.xlabel('Source Frequency')
#     plt.ylabel('Sample to Source Frequency Ratio')
#     plt.xticks(slow_range)
#     plt.yticks(fast_range)
#     proportion_plot_path = '../results/figures/shmoo/proportions/' + shmoo_proportion_title + '.pdf'
#     plt.savefig(proportion_plot_path)
#     plt.close(3)

# zero_count = data.count("0")
# ones_count = data.count("1")
# print("Number of 0s: " + str(zero_count))
# print("Number of 1s: " + str(ones_count))

# parsed_data = ', '.join(data)
# # print(parsed_data)
# f1 = open("parsed_test29.txt", "w")
# f1.write(parsed_data)
# f1.close()
