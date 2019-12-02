a,b = [int(n) for n in open('input.txt','r').read().split('\n')[0:-2]],[]
while any(a):
    a=[n/3-2 if n/3-2>0 else 0 for n in a]
    b+=[sum(a),]
print 'part 1:',b[0],'part 2:',sum(b)
