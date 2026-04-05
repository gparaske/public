# Μεταβλητές (Variables)

- Ορισμός Αριθμού (Numeric):
```
i = 123.45
```
- Ορισμός Αλφαριθμητικού (Alphanumeric - String):  
```
name = "Alice"
name = input("Πώς σε λένε; ")
```
- Μετατροπή Αριθμού σε String και Concat:  
```
result = "My name is " + name + " and I am " + str(age) + " years old."  
result = f"My name is {name} and I am {age} years old."  
print(result)
```

# Αρχεία
- Διαγραφή, Δημιουργία και Διάβασμα:
```
import os

filename = "demo.txt"

if os.path.exists(filename):
    os.remove(filename)

with open(filename, "w", encoding="utf-8") as f:
    f.write("Hello World\n")

with open(filename, "r", encoding="utf-8") as f:
    content = f.read()

print(content)
```

# Loops
- Με for από 0 έως 9:
```
for x in range(10)
    print(x)
```
- Με while:
```
x = 0
while x < 10:
    print(x)
    x += 1
```

# Arrays
- Append σε λίστα:
```
names = []
ages = []
names.append("George")
ages.append(46)
names.append("Theo")
ages.append(14)
names.append("Nick")
ages.append(13)
print("Names:", names)
print("Ages:", ages)
x = 0
for name in names:
    print(f"Hello {name}, you are {ages[x]} years old.")
    x += 1
```
- Join με delimeter αλφαριθμητικά ή αριθμοί:
```
join = ";".join(names)
join = ";".join(map(str, ages))
```
- Split με delimeter:
```
text = "George;Theodore;Nick"
names = text.split(";")
```
