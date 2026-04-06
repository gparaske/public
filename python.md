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

# names.append("George")
# ages.append(46)
# names.append("Theodore")
# ages.append(14)
# names.append("Nick")
# ages.append(13)

running = True
while running:
    name = input("Enter a name (or Enter for exit): ")
    if name == "":
        running = False
        continue
    age = input("Enter an age: ")

    names.append(name)
    ages.append(age)

for x in range(len(names)):
    print(names[x])
    print(ages[x])
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

# Graphics
```
import pygame

pygame.init()

# Δημιουργία παραθύρου
screen = pygame.display.set_mode((400, 400))
pygame.display.set_caption("Τίτλος Παραθύρου")

# Συντεταγμένες του τετραγώνου
x = 150
y = 150

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        # Έλεγχος πληκτρολογίου
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_LEFT:
                x -= 20
            if event.key == pygame.K_RIGHT:
                x += 20
            if event.key == pygame.K_ESCAPE:
                running = False

    # Γέμισμα φόντου
    screen.fill((30, 30, 30))

    # Ζωγραφίζω ένα τετράγωνο (x, y, width, height)
    pygame.draw.rect(screen, (0, 200, 255), (x, y, 100, 100))

    pygame.display.flip()

pygame.quit()
```

# Timer
```
clock = pygame.time.Clock()
speed = 0.5  # δευτερόλεπτα
# Δημιουργώ custom event
DROP_EVENT = pygame.USEREVENT + 1
pygame.time.set_timer(DROP_EVENT, int(speed * 1000))  # ms
...
while running:
    ...
        if event.type == DROP_EVENT:
            y += 20   # πέφτει 20 pixels
    ...
    clock.tick(60)
...
```
