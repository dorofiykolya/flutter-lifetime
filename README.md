# Lifetime

Flutter project

## Getting Started

### define
```
final definition = Lifetime.eternal.defineNested();
definition.lifetime.add(() => print("terminated"));
definition.terminate();
```

### intersection
```
final def1 = Lifetime.eternal.defineNested();
final def2 = Lifetime.eternal.defineNested();

final defIntersection = Lifetime.intersection([def1.lifetime, def2.lifetime]);
defIntersection.lifetime.add(() { print("def1 or def2 is terminated"); });

def1.terminate();
```

### nested
```
final def1 = Lifetime.eternal.defineNested();
final def2 = def1.defineNested();

def1.lifetime.add(() => print("def1 is terminated"));
def2.lifetime.add(() => print("def2 is terminated"));

def1.terminate();
```