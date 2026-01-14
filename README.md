# ObjVlisp - A Minimal Reflective Object-Oriented Kernel

A complete implementation of the ObjVlisp reflective micro-kernel in Pharo Smalltalk.

## 📋 Overview

This project implements ObjVlisp, a minimal and reflective object-oriented language model designed by Pierre Cointe and inspired by the Smalltalk-78 kernel. The system demonstrates that a complete and self-sufficient object-oriented environment can be built with only two fundamental classes: `Object` and `Class`.

### Key Features

- **Minimal Kernel**: A fully functional object-oriented system in less than 30 methods
- **Self-Bootstrapping**: The system constructs itself in three phases
- **Complete Reflexivity**: Classes are objects that can be introspected and modified
- **Explicit Metaclasses**: Full control over class behavior
- **Advanced Extensions**: Abstract classes, automatic accessor generation, shared variables

## 🏗️ Architecture

### Fundamental Classes

- **ObjObject**: Root of the inheritance hierarchy, defines base behavior for all objects
- **ObjClass**: The class of classes, controls class creation and structure

### Object Structure

```smalltalk
#(ClassId value1 value2 ... valueN)
```

Where:
- `ClassId`: Symbol identifying the instance's class
- `value1, value2, ...`: Instance variable values in declaration order

### Class Structure

```smalltalk
#(metaclass name superclass ivs keywords methodDict sharedVariables)
```

Where:
- `metaclass`: Symbol identifying the metaclass
- `name`: Class name (symbol)
- `superclass`: Parent class identifier
- `ivs`: Ordered collection of all instance variables (including inherited)
- `keywords`: Initialization keywords (Lisp-style)
- `methodDict`: Dictionary mapping selectors to method implementations
- `sharedVariables`: Class variables shared across all instances

## 🚀 Getting Started

### Prerequisites

- Pharo Smalltalk (version 10 or higher recommended)

### Installation

1. Clone the repository or load the source files into Pharo
2. Bootstrap the system:

```smalltalk
Obj bootstrap.
```

### Basic Usage Example

```smalltalk
"Create a Point class"
pointClass := (Obj giveClassNamed: #ObjClass)
    send: #new
    withArguments: #(#(name: #ObjPoint
                       iv: #(x y)
                       superclass: #ObjObject)).

"Create an instance"
aPoint := pointClass 
    send: #new 
    withArguments: #(#(x: 10 y: 20)).

"Access instance variables"
aPoint send: #getIV withArguments: {#x}. "=> 10"
```

## 🎯 Implemented Features

### Core Kernel

- ✅ Object allocation and initialization
- ✅ Instance variables with static inheritance
- ✅ Message sending and method lookup
- ✅ Super calls with currying
- ✅ Error handling (message not understood)
- ✅ Three-phase bootstrap

### Advanced Extensions

#### 1. Abstract Classes (`ObjAbstractClass`)

Prevents direct instantiation through metaclass-level control:

```smalltalk
abstractClass := objAbstractClass
    send: #new
    withArguments: #(#(name: #AbstractPoint
                       iv: #(x y)
                       superclass: #ObjObject)).

"Attempt to instantiate fails"
abstractClass send: #new withArguments: #(#(x: 10 y: 20)).
"=> Error: Cannot instantiate abstract class"
```

#### 2. Automatic Accessor Generation (`ObjClassWithAccessors`)

Automatically creates getters and setters for all instance variables:

```smalltalk
personClass := objClassWithAccessors
    send: #new
    withArguments: #(#(name: #Person
                       iv: #(name age email)
                       superclass: #ObjObject)).

"Accessors generated automatically"
person send: #name withArguments: #(). "=> getter"
person send: #age: withArguments: #(25). "=> setter"
```

#### 3. Shared Variables (Class Variables)

Class variables shared among all instances:

```smalltalk
workstationClass := (Obj giveClassNamed: #ObjClass)
    send: #new
    withArguments: #(#(name: #Workstation
                       iv: #(ipAddress computerName)
                       superclass: #ObjObject
                       sharedVariables: #((domain 'inria.fr')
                                         (defaultPrinter 'hp-laser-42')))).

"Access from class"
workstationClass send: #sharedVariableValue: withArguments: {#domain}.
"=> 'inria.fr'"

"Modification visible to all instances"
workstationClass send: #sharedVariableValue:put: 
    withArguments: {#domain. 'mit.edu'}.
```

#### 4. Secure Super (`superFrom:`)

Automatic context capture to prevent errors in super calls:

```smalltalk
"Define method with secure super"
coloredPointClass
    addMethod: #display
    args: ''
    withBody: 
        'objself superFrom: superClassOfClassDefiningTheMethod.
         "Add colored point specific display code"
         objself'.
```

The selector and arguments are automatically captured from the execution context, eliminating the risk of manual errors.

## 🧪 Testing

The project includes a comprehensive test suite covering all aspects of the system:

```smalltalk
"Run all tests"
ObjUserClassesTest suite run.
```

### Test Coverage

- **Bootstrap**: Manual creation, proper recreation, fixed point
- **User Classes**: Creation, inheritance, polymorphism
- **Message Sending**: Simple sends, super calls, error handling
- **Shared Variables**: Initialization, access, sharing, modification
- **Abstract Classes**: Instantiation prevention, inheritance
- **Automatic Accessors**: Generation, functionality
- **Secure Super**: Automatic capture, protection against modifications

### Example Test

```smalltalk
testSharedVariablesSharedAcrossInstances
    "Verify that all instances share the same variable"
    | ws1 ws2 |
    
    ws1 := workstationClass
        send: #new
        withArguments: #(#(ipAddress: '192.168.1.10'
                          computerName: 'ws1')).
    
    ws2 := workstationClass
        send: #new
        withArguments: #(#(ipAddress: '192.168.1.11'
                          computerName: 'ws2')).
    
    "Both instances see the initial value"
    self assert: (ws1 send: #getDomain withArguments: #())
         equals: 'inria.fr'.
    
    "Modify shared variable at class level"
    workstationClass
        send: #sharedVariableValue:put:
        withArguments: {#domain. 'stanford.edu'}.
    
    "Both instances immediately see the new value"
    self assert: (ws1 send: #getDomain withArguments: #())
         equals: 'stanford.edu'.
```

## 📚 Understanding ObjVlisp

### The Bootstrap Paradox

ObjVlisp solves the chicken-and-egg problem of object-oriented systems: how to create the first class when you need a class to create classes?

**Phase 1 - Manual Creation**: Create `ObjClass` manually as an array. It pretends to inherit from `ObjObject` which doesn't exist yet.

**Phase 2 - First Real Class**: Use the manual `ObjClass` to create `ObjObject` normally, proving the system works.

**Phase 3 - Proper Reconstruction**: Recreate `ObjClass` properly using inheritance from `ObjObject`. The system is now consistent and self-sufficient.

### Explicit vs. Implicit Metaclasses

**ObjVlisp (Explicit)**: The programmer chooses which metaclass to use for each class. This provides maximum flexibility - you can mix different metaclasses in the same hierarchy.

**Pharo (Implicit)**: The system automatically creates a metaclass for each class. The metaclass hierarchy mirrors the class hierarchy (isomorphic). This is simpler but less flexible.

### Everything is an Object

In ObjVlisp, there's only one mechanism: message sending. Whether reading a variable, creating an object, or defining a class, you send a message.

A class plays two simultaneous roles:
1. **Template for instances**: Defines structure (variables) and behavior (methods)
2. **Object itself**: Can receive messages like any other object

## 🔧 Implementation Details

### Object Representation

Objects are represented as Pharo arrays (instances of `Obj`, a subclass of `Array`). This allows us to focus on the essence of the model without implementing a full compiler.

### Method Representation

Methods are Pharo blocks (closures) stored in the class's method dictionary. A two-level block structure implements currying to bind the superclass at definition time:

```smalltalk
[:superClassOfClassDefiningTheMethod |
    [:objself :arg1 :arg2 |
        "method body"
    ]
]
```

### Message Sending

The `send:withArguments:` primitive combines method lookup and execution:
1. Start lookup from the receiver's class
2. Search recursively up the inheritance hierarchy
3. Execute the method if found
4. Send `error` message if not found

## 📖 Project Documentation

For a detailed technical report (in French), see the included PDF document which covers:
- Complete implementation details
- Bootstrap process explanation
- Advanced extension implementations
- Testing methodology
- Lessons learned and future perspectives

## 📜 License and Copyright

### Original Work Attribution

This implementation is based on the ObjVlisp model, which is inspired by concepts described in educational materials by Stéphane Ducasse and the Pharo community.

**Copyright 2017 by Stéphane Ducasse**

The foundational concepts and educational content related to ObjVlisp are protected under the **Creative Commons Attribution-ShareAlike 3.0 Unported License**.

### License Terms

You are free to:
- **Share**: Copy, distribute and transmit the work
- **Remix**: Adapt the work

Under the following conditions:
- **Attribution**: You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work)
- **ShareAlike**: If you alter, transform, or build upon this work, you may distribute the resulting work only under the same, similar or a compatible license

For any reuse or distribution, you must make clear to others the license terms of this work. The best way to do this is with a link to:

**http://creativecommons.org/licenses/by-sa/3.0/**

Any of the above conditions can be waived if you get permission from the copyright holder. Nothing in this license impairs or restricts the author's moral rights.

Your fair dealing and other rights are in no way affected by the above.

This is a human-readable summary of the Legal Code (the full license):  
**http://creativecommons.org/licenses/by-sa/3.0/legalcode**

### This Implementation

This specific implementation and its documentation are released under the same **CC BY-SA 3.0** license, maintaining consistency with the educational materials that inspired it.

## 🤝 Contributing

This is an educational project demonstrating object-oriented system implementation. Contributions, suggestions, and discussions about the implementation are welcome.

---

**Note**: This implementation is for educational purposes, demonstrating fundamental concepts of object-oriented programming, reflection, and metaprogramming. It serves as a learning tool to understand how object-oriented systems work at their core.
