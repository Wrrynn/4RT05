from pathlib import Path
s=Path('lib/pages/homePage.dart').read_text()
open_br=s.count('[')
close_br=s.count(']')
print('open [',open_br,'close ]',close_br)
stack=[]
for i,ch in enumerate(s):
    if ch=='[':
        stack.append(i)
    elif ch==']':
        if stack:
            stack.pop()
        else:
            print('Extra ] at',i)
            break
if stack:
    print('Unclosed [ at positions (first few):',stack[:5])
    pos=stack[-1]
    start=max(0,pos-120)
    end=min(len(s),pos+120)
    print('Context around last unclosed [:\n')
    print(s[start:end])
else:
    print('All square brackets matched')
