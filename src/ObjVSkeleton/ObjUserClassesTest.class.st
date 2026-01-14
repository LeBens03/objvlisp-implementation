Class {
	#name : #ObjUserClassesTest,
	#superclass : #TestCase,
	#instVars : [
		'aPoint',
		'pointColoredClass',
		'pointClass',
		'aPointColored',
		'abstractPointClass',
		'objClassWithAccessors',
		'pointColoredClassWithAccessors',
		'aPointColoredWithAccessors',
		'workstationClass'
	],
	#category : #ObjVSkeleton
}

{ #category : #setup }
ObjUserClassesTest >> assembleAbstractClass [ 
    Obj createObjAbstractClass.
	
]

{ #category : #setup }
ObjUserClassesTest >> assembleAbstractPointClass [ 
    abstractPointClass := Obj createObjAbstractPoint.
	
]

{ #category : #setup }
ObjUserClassesTest >> assembleClassWithAccessors [ 
    objClassWithAccessors := Obj createObjClassWithAccessors.
	
]

{ #category : #setup }
ObjUserClassesTest >> assemblePointClass [ 
    pointClass := Obj createObjPoint.
	
]

{ #category : #setup }
ObjUserClassesTest >> assemblePointClassWithAccessors [
	objClassWithAccessors
        send: #new
        withArguments: #((#name: #ObjAutoPoint 
                        #iv: #(#x #y) 
                        #superclass: #ObjObject)).
]

{ #category : #setup }
ObjUserClassesTest >> assemblePointColoredClass [ 
    pointColoredClass := Obj createObjPointColored.
	
]

{ #category : #setup }
ObjUserClassesTest >> assemblePointColoredClassWithAccessors [
	pointColoredClassWithAccessors := objClassWithAccessors
        send: #new
        withArguments: #((#name: #ObjAutoColoredPoint 
                        #iv: #(#color) 
                        #superclass: #ObjAutoPoint)).
]

{ #category : #setup }
ObjUserClassesTest >> assemblePointColoredInstance [
    aPointColored := pointColoredClass send: #new withArguments: #((#x: 24 #y: 6 #color: 'blue')).
	
]

{ #category : #setup }
ObjUserClassesTest >> assemblePointColoredInstanceWithAccessors [
	aPointColoredWithAccessors := pointColoredClassWithAccessors  
        send: #new 
        withArguments: #((#x: 10 #y: 20 #color: #red)).
]

{ #category : #setup }
ObjUserClassesTest >> assemblePointInstance [ 
    aPoint := pointClass send: #new withArguments: #((#x: 24 #y: 6)).
]

{ #category : #setup }
ObjUserClassesTest >> assembleWorkStationClass [
	workstationClass := (Obj giveClassNamed: #ObjClass)
        send: #new
        withArguments: #((#name: #ObjWorkstation
                         #iv: #(ipAddress computerName)
                         #superclass: #ObjObject
                         #sharedVariables: #((domain 'inria.fr') (defaultPrinter 'hp-laser')))).
]

{ #category : #setup }
ObjUserClassesTest >> setUp [
	"self new setUp"
	super setUp.
	Obj bootstrap.
	self assemblePointClass.
	self assemblePointColoredClass.
	self assemblePointInstance.
	self assemblePointColoredInstance.
	self assembleAbstractClass.
	self assembleAbstractPointClass.
	self assembleClassWithAccessors.
	self assemblePointClassWithAccessors.
	self assemblePointColoredClassWithAccessors.
	self assemblePointColoredInstanceWithAccessors.
	self assembleWorkStationClass.
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testAccessSharedVariableValue [
    "Test accessing shared variable values"
    | workStationClass domainValue printerValue |

	 workStationClass := (Obj giveClassNamed: #ObjClass)
        send: #new
        withArguments: #((#name: #ObjWorkstation
                         #iv: #(ipAddress computerName)
                         #superclass: #ObjObject
                         #sharedVariables: #((domain 'inria.fr') (defaultPrinter 'hp-laser')))).
    
    "Access shared variable values"
    domainValue := workStationClass 
        send: #sharedVariableValue: 
        withArguments: {#domain}.
    
    printerValue := workStationClass 
        send: #sharedVariableValue: 
        withArguments: {#defaultPrinter}.
    
    self assert: domainValue equals: 'inria.fr'.
    self assert: printerValue equals: 'hp-laser'.
]

{ #category : #'tests-ObjClassWithAccessors' }
ObjUserClassesTest >> testAccessorsWithInheritance [
    "Test that accessors are generated for inherited IVs too"
    
    "Test accessors for inherited IVs (x, y)"
    self assert: (aPointColoredWithAccessors send: #x withArguments: #()) equals: 10.
    self assert: (aPointColoredWithAccessors send: #y withArguments: #()) equals: 20.
    
    "Test accessors for local IV (color)"
    self assert: (aPointColoredWithAccessors send: #color withArguments: #()) equals: #red.
    
    "Test setters"
    aPointColoredWithAccessors send: #x: withArguments: #(100).
    aPointColoredWithAccessors send: #color: withArguments: #(#blue).
    
    self assert: (aPointColoredWithAccessors send: #x withArguments: #()) equals: 100.
    self assert: (aPointColoredWithAccessors send: #color withArguments: #()) equals: #blue.
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testAddSharedVariableDynamically [
    "Test adding a shared variable after class creation"
    | workStationClass value |

	 workStationClass := (Obj giveClassNamed: #ObjClass)
        send: #new
        withArguments: #((#name: #ObjWorkstation
                         #iv: #(ipAddress computerName)
                         #superclass: #ObjObject
                         #sharedVariables: #((domain 'inria.fr')))).
    
    "Initially has only one shared variable"
    self assert: workStationClass objSharedVariables size equals: 1.
    
    "Add a new shared variable"
    workStationClass 
        send: #sharedVariableValue:put: 
        withArguments: {#timezone. 'UTC+1'}.
    
    "Now has two shared variables"
    self assert: workStationClass objSharedVariables size equals: 2.
    
    "Can access the new shared variable"
    value := workStationClass 
        send: #sharedVariableValue: 
        withArguments: {#timezone}.
    
    self assert: value equals: 'UTC+1'.
]

{ #category : #'tests-ObjClassWithAccessors' }
ObjUserClassesTest >> testAutoGeneratedAccessors [
    "Test that accessors are automatically generated for instance variables"
    
	 "Test that getters were auto-generated"
    self assert: (aPointColoredWithAccessors send: #x withArguments: #()) equals: 10.
    self assert: (aPointColoredWithAccessors send: #y withArguments: #()) equals: 20.
    
    "Test that setters were auto-generated"
    aPointColoredWithAccessors send: #x: withArguments: #(30).
    aPointColoredWithAccessors send: #y: withArguments: #(40).
    
    self assert: (aPointColoredWithAccessors send: #x withArguments: #()) equals: 30.
    self assert: (aPointColoredWithAccessors send: #y withArguments: #()) equals: 40.
    
    
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testCreateClassWithSharedVariables [
    "Test creating a class with shared variables"
    
    "Verify class was created"
    self assert: workstationClass isNotNil.
    self assert: (workstationClass send: #isClass withArguments: #()) equals: true.
    
    "Verify shared variables storage exists"
    self assert: workstationClass objSharedVariables isNotNil.
    self assert: workstationClass objSharedVariables size equals: 2.
]

{ #category : #'tests-ObjAbstractPoint' }
ObjUserClassesTest >> testCreateObjAbstractPointClass [
    "Test that we can create the ObjAbstractPoint class"
    
    self assert: abstractPointClass isNotNil.
    self assert: (abstractPointClass send: #isClass withArguments: #()) equals: true.
    self assert: (Obj giveClassNamed: #ObjAbstractPoint) equals: abstractPointClass.
]

{ #category : #'tests-ObjClassWithAccessors' }
ObjUserClassesTest >> testCreateObjClassWithAccessors [
    "Test that we can create the ObjClassWithAccessors metaclass"
    
    self assert: objClassWithAccessors isNotNil.
    self assert: (objClassWithAccessors send: #isClass withArguments: #()) equals: true.
]

{ #category : #'tests-ObjPoint' }
ObjUserClassesTest >> testCreateObjPointClass [
    "Test that we can create the ObjPoint class"
    
    self assert: pointClass isNotNil.
    self assert: (pointClass send: #isClass withArguments: #()) equals: true.
    self assert: (Obj giveClassNamed: #ObjPoint) equals: pointClass.
]

{ #category : #'tests-ObjPointColored' }
ObjUserClassesTest >> testCreateObjPointColoredClass [
    "Test that we can create the ObjPointColored class"
    
    self assert: pointColoredClass isNotNil.
    self assert: (pointColoredClass send: #isClass withArguments: #()) equals: true.
    self assert: (Obj giveClassNamed: #ObjColoredPoint) equals: pointColoredClass.
]

{ #category : #'tests-ObjPointColored' }
ObjUserClassesTest >> testCreateObjPointColoredInstance [
    "Test that we can create an instance of ObjPointColored"
    
    self assert: aPointColored isNotNil.
    self assert: (aPointColored send: #class withArguments: #()) equals: pointColoredClass.
]

{ #category : #'tests-ObjPoint' }
ObjUserClassesTest >> testCreateObjPointInstance [
    "Test that we can create an instance of ObjPoint"
    
    self assert: aPoint isNotNil.
    self assert: (aPoint send: #class withArguments: #()) equals: pointClass.
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testErrorOnNonExistentSharedVariable [
    "Test that accessing a non-existent shared variable raises an error"
    
    "Accessing existing shared variable works"
    self shouldnt: [workstationClass send: #sharedVariableValue: withArguments: {#domain}] 
         raise: Error.
    
    "Accessing non-existent shared variable raises error"
    self should: [workstationClass send: #sharedVariableValue: withArguments: {#nonExistent}] 
         raise: Error.
]

{ #category : #'tests-ObjAbstractPoint' }
ObjUserClassesTest >> testInstanceObjAbstractPointClass [
    "Test that we can create the ObjAbstractPoint class instance"

	 | abstractPoint |

	 abstractPoint := Obj createObjAbstractClass.

	 self should: [abstractPoint send: #new withArguments: #(#(#x: 24 #y: 6))] raise: Error
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testModifySharedVariableValue [
    "Test modifying shared variable values"
    | newValue |
    
    "Initial value"
    self assert: (workstationClass send: #sharedVariableValue: withArguments: {#domain}) 
         equals: 'inria.fr'.
    
    "Modify the shared variable"
    workstationClass 
        send: #sharedVariableValue:put: 
        withArguments: {#domain. 'mit.edu'}.
    
    "Verify new value"
    newValue := workstationClass 
        send: #sharedVariableValue: 
        withArguments: {#domain}.
    
    self assert: newValue equals: 'mit.edu'.
]

{ #category : #'tests-ObjPointColored' }
ObjUserClassesTest >> testObjPointColoredDisplay [
    
    self shouldnt: [aPointColored send: #display withArguments: #()] raise: Error.
]

{ #category : #'tests-ObjPointColored' }
ObjUserClassesTest >> testObjPointColoredGetIV [
    "Test getting instance variable values"
    | colorValue |
    
    colorValue := aPointColored send: #color withArguments: #().
    
    self assert: colorValue equals: 'blue'.
]

{ #category : #'tests-ObjPointColored' }
ObjUserClassesTest >> testObjPointColoredSetIV [
    "Test setting instance variable values"
    | colorValue |
    
    aPointColored send: #color: withArguments: #('red').
	 colorValue := aPointColored send: #color withArguments: #().
    
    self assert: colorValue equals: 'red'.
]

{ #category : #'tests-ObjPoint' }
ObjUserClassesTest >> testObjPointDisplay [

	 self shouldnt: [aPoint send: #display withArguments: #()] raise: Error.
]

{ #category : #'tests-ObjPoint' }
ObjUserClassesTest >> testObjPointGetIV [
    "Test getting instance variable values using getIV"
    | xValue yValue |
    
    xValue := aPoint send: #givex withArguments: #().
    yValue := aPoint send: #givey withArguments: #().
    
    self assert: xValue equals: 24.
    self assert: yValue equals: 6.
]

{ #category : #'tests-ObjPoint' }
ObjUserClassesTest >> testObjPointInheritsFromObjObject [
    "Test that ObjPoint instances can use ObjObject methods"
    | isClass isMetaclass |
    
    isClass := aPoint send: #isClass withArguments: #().
    isMetaclass := aPoint send: #isMetaclass withArguments: #().
    
    self assert: isClass equals: false.
    self assert: isMetaclass equals: false.
]

{ #category : #'tests-ObjPoint' }
ObjUserClassesTest >> testObjPointSetIV [
    "Test setting instance variable values using setIV"
    | xValue yValue |
    
    aPoint send: #x: withArguments: #(25).
    aPoint send: #y: withArguments: #(7).
    
    xValue := aPoint send: #getIV withArguments: #(#x).
    yValue := aPoint send: #getIV withArguments: #(#y).
    
    self assert: xValue equals: 25.
    self assert: yValue equals: 7.
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testSharedVariablesNotInInstanceVariableList [
    "Test that shared variables are not listed as instance variables"
    | ivs |
    
    "Get instance variables"
    ivs := workstationClass objIVs.
    
    "Instance variables should be: class, ipAddress, computerName"
    self assert: ivs size equals: 3.
    self assert: (ivs includes: #class).
    self assert: (ivs includes: #ipAddress).
    self assert: (ivs includes: #computerName).
    
    "Shared variable 'domain' should NOT be in instance variables"
    self deny: (ivs includes: #domain).
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testSharedVariablesSeparateFromInstanceVariables [
    "Test that shared variables don't interfere with instance variables"
    | ws1 ws2 |
    
    "Create instances with different instance variables"
    ws1 := workstationClass 
        send: #new 
        withArguments: #((#ipAddress: '192.168.1.10' #computerName: 'ws1')).
    
    ws2 := workstationClass 
        send: #new 
        withArguments: #((#ipAddress: '192.168.1.11' #computerName: 'ws2')).
    
    "Instance variables are different"
    self assert: (ws1 send: #getIV withArguments: {#ipAddress}) equals: '192.168.1.10'.
    self assert: (ws2 send: #getIV withArguments: {#ipAddress}) equals: '192.168.1.11'.
    
    "But shared variable is the same"
    workstationClass
        addUnaryMethod: #getDomain
        withBody: 'objself objClass send: #sharedVariableValue: withArguments: {#domain}'.
    
    self assert: (ws1 send: #getDomain withArguments: #()) 
         equals: (ws2 send: #getDomain withArguments: #()).
]

{ #category : #'tests-SharedVariables' }
ObjUserClassesTest >> testSharedVariablesSharedAcrossInstances [
    "Test that all instances of a class share the same variable"
    | ws1 ws2 |
    
    "Add method to access shared variable from instances"
    workstationClass
        addUnaryMethod: #getDomain
        withBody: 'objself objClass send: #sharedVariableValue: withArguments: {#domain}'.
    
    "Create two instances"
    ws1 := workstationClass 
        send: #new 
        withArguments: #((#ipAddress: '192.168.1.10' #computerName: 'ws1')).
    
    ws2 := workstationClass 
        send: #new 
        withArguments: #((#ipAddress: '192.168.1.11' #computerName: 'ws2')).
    
    "Both instances see the same value"
    self assert: (ws1 send: #getDomain withArguments: #()) equals: 'inria.fr'.
    self assert: (ws2 send: #getDomain withArguments: #()) equals: 'inria.fr'.
    
    "Change the shared variable at class level"
    workstationClass 
        send: #sharedVariableValue:put: 
        withArguments: {#domain. 'stanford.edu'}.
    
    "Both instances see the new value"
    self assert: (ws1 send: #getDomain withArguments: #()) equals: 'stanford.edu'.
    self assert: (ws2 send: #getDomain withArguments: #()) equals: 'stanford.edu'.

]

{ #category : #'tests-ObjClassWithRedefinedSuperCall' }
ObjUserClassesTest >> testSuperFrom [
    "Test that callSuperFrom: automatically captures selector and arguments"
    
    "Add a method to ObjPoint"
    pointClass := Obj giveClassNamed: #ObjPoint.
    pointClass
        addMethod: #setXY:
        args: 'newX newY'
        withBody: 
            'objself send: #setIV withArguments: {#x. newX}.
            objself send: #setIV withArguments: {#y. newY}.
            objself'.
    
    "Add a method to ObjColoredPoint that uses superFrom:"
    pointColoredClass := Obj giveClassNamed: #ObjColoredPoint.
    pointColoredClass
        addMethod: #setXY:
        args: 'newX newY'
        withBody: 
            'objself superFrom: superClassOfClassDefiningTheMethod.
            objself'.
    
    "Call the method - should automatically call super with same selector and args"
    aPointColored send: #setXY: withArguments: #(50 75).
    
    "Verify the super call worked - both x and y should be updated"
    self assert: (aPointColored send: #getIV withArguments: {#x}) equals: 50.
    self assert: (aPointColored send: #getIV withArguments: {#y}) equals: 75.
]
