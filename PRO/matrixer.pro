n=5
m=3
a=randomu(seed,n)
b=randomu(seed,m)
c=a#transpose(b)
print,'c:',c

an=reform(c[*,0])
bn=reform(c[0,*]/an[0])

print,'an#transpose(bn):',an#transpose(bn)

 print,'a: ',a
 print,'an:',an
 print,'a/an:',a/an
  print,'b: ',b
 print,'bn:',bn
 print,'b/bn:',b/bn,1./(b/bn)
end