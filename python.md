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
