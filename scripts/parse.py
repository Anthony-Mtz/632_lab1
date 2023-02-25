# output = open('results/final.txt', 'w+')

zero_count = 0
one_count = 0

# with open('TRNG_data/config_H_8.txt', 'r', encoding='ascii') as f:
with open('TRNG_data/config_I_64.txt', 'r', encoding='ascii') as f:
    for i in range(1000000):
        # output.write(f.read(1))
        value = (f.read(1))
        # print(value)
        if(value == '0'): zero_count += 1
        elif(value == '1'): one_count += 1
    
    print("zero count:", zero_count)
    print("ones count:", one_count)


        # if i in range(1000000,(11*1000000), 1000000): output.write('\n')



