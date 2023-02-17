output = open('results/final.txt', 'w+')



with open('results/output_ring_2.txt', 'r', encoding='ascii') as f:
    for i in range(10*1000000):
        output.write(f.read(1))
        if i in range(1000000,(11*1000000), 1000000): output.write('\n')



