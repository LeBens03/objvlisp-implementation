Class {
	#name : #Obj,
	#superclass : #Array,
	#type : #variable,
	#classInstVars : [
		'definedObjClasses'
	],
	#category : #ObjVSkeleton
}

{ #category : #'bootstrap objMessage' }
Obj class >> addMessagesForErrorHandling [
	"pre condition message has been created (and declared)"
	"self addMessagesForErrorHandling"
	| objMessage |
	objMessage := self ObjMessage.

	objMessage 
		addUnaryMethod: #receiver 
		withBody: 'objself valueOfInstanceVariable: #receiver'.

	objMessage 
		addUnaryMethod: #receiver2 
		withBody: 'objself send: #getIV withArguments: #(#receiver)'.

	objMessage 
		addUnaryMethod: #selector 
		withBody: 'objself send: #getIV withArguments: #(#selector)'.
		
	objMessage 
		addUnaryMethod: #arguments 
		withBody: 'objself send: #getIV withArguments: #(#arguments)'.
	
	objMessage 
		addMethod: #setReceiver
		args: 'receiver'
		withBody:' objself send: #setIV withArguments: (Array with: #receiver with: receiver)'.
		
	objMessage 
		addMethod: #setSelector
		args: 'selector'
		withBody:' objself send: #setIV withArguments: (Array with: #selector with: selector)'.

	objMessage 
		addMethod: #setArguments
		args: 'arguments'
		withBody:' objself send: #setIV withArguments: (Array with: #arguments with: arguments)'.		
				
	^ objMessage 
]

{ #category : #'bootstrap objClass manually' }
Obj class >> bootstrap [
	"self bootstrap"
	
	self initialize.
	self manuallyCreateObjClass.
	self createObjObject.
	self createObjClass.
]

{ #category : #'meta data' }
Obj class >> classInstanceVariables [
	^ #(#class #name #superclass #iv #keywords #methodDict #sharedVariables)
]

{ #category : #'user meta classes' }
Obj class >> createObjAbstractClass [
    | abstractClass |
    
    abstractClass := (self giveClassNamed: #ObjClass)
        send: #new
        withArguments: #((#name: #ObjAbstractClass 
                         #iv: #() 
                         #superclass: #ObjClass)).
	 abstractClass
        addUnaryMethod: #isAbstractMetaclass
        withBody: 'true'.

	 abstractClass 
		addMethod: #new
		args: 'initArray' 
		withBody:
            '| receiverClass |
            receiverClass := objself send: #class withArguments: #().
            (receiverClass send: #isAbstractMetaclass withArguments: #())
                ifTrue: [objself send: #error 
                            withArguments: {objself. 
                                          #new. 
                                          ''Cannot instantiate abstract class''}]
                ifFalse: [objself super: #new 
                            withArguments: {initArray} 
                            from: superClassOfClassDefiningTheMethod.]'.
        
    ^ abstractClass
]

{ #category : #'user classes' }
Obj class >> createObjAbstractPoint [
    | abstractPointClass |
    
    abstractPointClass := (self giveClassNamed: #ObjAbstractClass)
        send: #new
        withArguments: #((#name: #ObjAbstractPoint #iv: #() #superclass: #ObjPoint)).
    
    ^ abstractPointClass
]

{ #category : #'bootstrap objClass' }
Obj class >> createObjClass [
	"self bootstrap"

	| objClass |
	objClass := self objClassStructure.
	self defineAllocateMethodIn: objClass.
	self defineNewMethodIn: objClass.
	self defineInitializeMethodIn: objClass.
	objClass 
		addUnaryMethod: #isMetaclass
		withBody: 'objself objIVs includes: #superclass'.	
	"an object is a class if is class is a metaclass. cool"
	
	objClass 
		addUnaryMethod: #isClass
		withBody: 'objself objClass send: #isMetaclass withArguments:#()'.
		
	objClass
        addMethod: #sharedVariableValue:
        args: 'varName'
        withBody: 
            '| sharedVars pair |
            sharedVars := objself objSharedVariables.
            pair := sharedVars detect: [:p | p first = varName] ifNone: [nil].
            pair isNil 
                ifTrue: [objself send: #error withArguments: (Array with: objself with: varName with: ''Shared variable not found'')]
                ifFalse: [pair second]'.
    
    objClass
        addMethod: #sharedVariableValue:put:
        args: 'varName newValue'
        withBody:
            '| sharedVars pair |
            sharedVars := objself objSharedVariables.
            pair := sharedVars detect: [:p | p first = varName] ifNone: [nil].
            pair isNil 
                ifTrue: [sharedVars add: (Array with: varName with: newValue)]
                ifFalse: [pair at: 2 put: newValue].
            objself'.

	^objClass
]

{ #category : #'user meta classes' }
Obj class >> createObjClassWithAccessors [
    | objClassWithAccessors |
    
    objClassWithAccessors := (self giveClassNamed: #ObjClass)
        send: #new
        withArguments: #((#name: #ObjAbstractClass 
                         #iv: #() 
                         #superclass: #ObjClass)).

	 self defineInitializeMethodWithAccessorsIn: objClassWithAccessors.
        
    ^ objClassWithAccessors
]

{ #category : #'bootstrap objObject' }
Obj class >> createObjObject [
	| objObject |
	objObject := self objObjectStructure.
	objObject addUnaryMethod: #class withBody: 'objself objClass'.
	objObject addUnaryMethod: #isClass withBody: 'false'.
	objObject addUnaryMethod: #isMetaclass withBody: 'false'. 
	objObject 
		addMethod: #error
		args: 'arrayOfArguments'
		withBody: 'Transcript show: ''error '', arrayOfArguments first.  ''error '', arrayOfArguments first'.

	"some meta facilities"
	objObject 
		addMethod: #getIV
		args: 'iv'
		withBody: 'objself valueOfInstanceVariable: iv'.

	objObject 
		addMethod: #setIV
		args: 'iv val'
		withBody: 
			' objself at: (objself offsetFromObjectOfInstanceVariable: iv) put: val'.

	objObject 
		addMethod: #initialize
		args: 'initargs'
		withBody: 'objself  initializeUsing: initargs'.
	^objObject
]

{ #category : #'user classes' }
Obj class >> createObjPoint [
    | pointClass |
    
    pointClass := (self giveClassNamed: #ObjClass)
        send: #new
        withArguments: #((#name: #ObjPoint #iv: #(#x #y) #superclass: #ObjObject)).
    
    pointClass 
        addUnaryMethod: #givex
        withBody: 'objself valueOfInstanceVariable: #x'.
    
    pointClass
        addMethod: #x:
        args: 'newX'
        withBody: 'objself send: #setIV withArguments: {#x. newX}. objself'.
    
    pointClass
        addUnaryMethod: #givey
        withBody: 'objself valueOfInstanceVariable: #y'.
    
    pointClass
        addMethod: #y:
        args: 'newY'
        withBody: 'objself send: #setIV withArguments: {#y. newY}. objself'.
    
    pointClass
        addUnaryMethod: #display
        withBody: 
            'Transcript cr;
            show: ''aPoint with x = ''.
            Transcript show: (objself send: #givex withArguments: #()) printString.
            Transcript show: '' and y = ''.
            Transcript show: (objself send: #givey withArguments: #()) printString;
            cr.
            objself'.
    
    ^ pointClass
]

{ #category : #'user classes' }
Obj class >> createObjPointColored [
    | pointColoredClass |
    
    pointColoredClass := (self giveClassNamed: #ObjClass)
        send: #new
        withArguments: #((#name: #ObjColoredPoint #iv: #(#color) #superclass: #ObjPoint)).
    
    pointColoredClass 
        addUnaryMethod: #color
        withBody: 'objself valueOfInstanceVariable: #color'.
    
    pointColoredClass
        addMethod: #color:
        args: 'newColor'
        withBody: 'objself send: #setIV withArguments: {#color. newColor}. objself'.
    
    pointColoredClass
        addUnaryMethod: #display
        withBody: 
            'objself super: #display withArguments: #() from: superClassOfClassDefiningTheMethod.
				Transcript cr;
				show: '' with Color = ''.
				Transcript show: (objself send: #giveColor withArguments: #()) printString; 
				cr'.   
				
    ^ pointColoredClass
]

{ #category : #'global class repository management' }
Obj class >> declareClass: anObjClass [ 
	"To declare an ObjClass in the class repository"

	| nameC |
	nameC := anObjClass objName.
	nameC isNil
		ifFalse: [definedObjClasses at: nameC put: anObjClass]
		ifTrue: [self error: 'The class does not have a name']
]

{ #category : #'bootstrap objClass manually' }
Obj class >> defineAllocateMethodIn: class [ 
	"The allocated obj method simply invokes the primitive allocateAnInstance."
	
	class 
		addUnaryMethod: #allocate 
		withBody: 'objself allocateAnInstance'
]

{ #category : #'bootstrap objClass' }
Obj class >> defineInitializeMethodIn: objClass [ 

	objClass 
		addMethod: #initialize
		args: 'initArray'
		withBody: 
			'objself super: #initialize withArguments: {initArray} from: superClassOfClassDefiningTheMethod.
			objself objIVs: (objself
							computeNewIVFrom: (Obj giveClassNamed: objself objSuperclassId) objIVs
							with: objself objIVs).
			objself computeAndSetKeywords.
			objself objMethodDict: IdentityDictionary new.
			objself objSharedVariables isNil ifTrue: [
          objself objSharedVariables: OrderedCollection new
         ].
			Obj declareClass: objself.
			objself'
]

{ #category : #'user meta classes' }
Obj class >> defineInitializeMethodWithAccessorsIn: objClassWithAccessors [
    objClassWithAccessors 
        addMethod: #initialize
        args: 'initArray'
        withBody: 
        '| ivs |
        objself super: #initialize 
            withArguments: {initArray} 
            from: superClassOfClassDefiningTheMethod.
        
        ivs := objself objIVs.
        
        ivs do: [:iv | 
            iv = #class ifFalse: [ 
                objself send: #generateAccessorsFor: withArguments: {iv}
            ]
        ].
        objself'.
        
    objClassWithAccessors 
        addMethod: #generateAccessorsFor:
        args: 'ivName'
        withBody: 
        '| getterName setterName |
        getterName := ivName. 
        setterName := (ivName asString, '':'') asSymbol.
        objself 
            addUnaryMethod: getterName
            withBody: ''objself send: #getIV withArguments: {#'', ivName asString, ''}''.
        objself 
            addMethod: setterName
            args: ''newValue''
            withBody: ''objself send: #setIV withArguments: {#'', ivName asString, ''. newValue}. objself''.
        objself'
]

{ #category : #'bootstrap objClass manually' }
Obj class >> defineManualInitializeMethodIn: class [ 

	class 
		addMethod: #initialize
		args: 'initArray'
		withBody: 	
			'| objsuperclass |
			objself initializeUsing: initArray.	"Initialize a class as an object. In the bootstrapped system will be done via super"
			objsuperclass := Obj giveClassNamed: objself objSuperclassId ifAbsent: [nil].
			objsuperclass isNil
				ifFalse: 
					[objself
						objIVs: (objself computeNewIVFrom: objsuperclass objIVs with: objself objIVs)]
				ifTrue: 
					[objself objIVs: (objself computeNewIVFrom: #(#class) with: objself objIVs)].
			objself
				objKeywords: (objself generateKeywords: (objself objIVs copyWithout: #class)).
			objself objMethodDict: (IdentityDictionary new: 3).
			"Only initialize if not already set by initializeUsing:"
            objself objSharedVariables isNil ifTrue: [
                objself objSharedVariables: OrderedCollection new
            ].
			Obj declareClass: objself.
			objself'
]

{ #category : #'bootstrap objClass manually' }
Obj class >> defineNewMethodIn: class [ 

	class 
		addMethod: #new
		args: 'initArray'
		withBody: 
			'(objself send: #allocate withArguments: #()) send: #initialize withArguments: { initArray } '.
]

{ #category : #tricks }
Obj class >> doesNotUnderstand: aMessage [

	"debugging >>>  default shiftDown ifTrue:[ self halt ]."
	"Sensor shiftPressed ifTrue:[ self halt ]."
	
	^ definedObjClasses at: aMessage selector
]

{ #category : #'global class repository management' }
Obj class >> giveClassNamed: aSymbol [ 
	"Return the class defined in the class repository with the name aSymbol"

	^ self giveClassNamed: aSymbol ifAbsent: [self error: ('The class ' , aSymbol printString , ' is not defined')]
]

{ #category : #'global class repository management' }
Obj class >> giveClassNamed: aSymbol ifAbsent: aBlock [

	^ definedObjClasses at: aSymbol ifAbsent: aBlock
]

{ #category : #initialize }
Obj class >> initialize [
	"self initialize"	
 
	definedObjClasses := IdentityDictionary new.
	definedObjClasses at: #ObjClass put: nil.
	definedObjClasses at: #ObjObject put: nil.
	definedObjClasses at: #ObjMessage put: nil.
]

{ #category : #'bootstrap objClass manually' }
Obj class >> manualObjClassStructure [
	| class |
	class := Obj new: 7.
	class objClassId: #ObjClass.
	class objName: #ObjClass.
	class objIVs: self classInstanceVariables.
	class objKeywords: #(#name: #superclass: #iv: #keywords: #methodDict: #sharedVariables:).
	class objSuperclassId: #ObjObject.
	class objMethodDict: (IdentityDictionary new: 3). 
	class objSharedVariables: OrderedCollection new.
	^ class
]

{ #category : #'bootstrap objClass manually' }
Obj class >> manuallyCreateObjClass [
	"self manuallyCreateObjClass"

	| class |
	class := self manualObjClassStructure.
	Obj declareClass: class.
	self defineManualInitializeMethodIn: class.
	self defineNewMethodIn: class.
	self defineAllocateMethodIn: class.
	^class
]

{ #category : #'bootstrap objClass' }
Obj class >> objClassStructure [
	^(Obj giveClassNamed: #ObjClass) send: #new
		withArguments: #(#(#name: #ObjClass #iv: #(#name #superclass #iv #keywords #methodDict #sharedVariables) #superclass: #ObjObject))
]

{ #category : #'bootstrap objMessage' }
Obj class >> objClassStructureMessage [
	^ Obj ObjClass 
		send: #new
		withArguments: #(#(#name: #ObjMessage #iv: #(#receiver #selector #arguments) #superclass: #ObjObject))
]

{ #category : #'bootstrap objObject' }
Obj class >> objObjectStructure [
	^(Obj giveClassNamed: #ObjClass) 
		send: #new
		withArguments: #(#(#name: #ObjObject #iv: #(#class)))
]

{ #category : #'skeleton metadata' }
Obj class >> selectorsToSkeletonize [
	"Skeletonizer new 
		selectors: Obj selectorsToSkeletonize;
		sourceClassName: #Obj;
		targetClassName: #ObjSkeleton;
		installClass;
		skeletonize
		"

	^ #(objIVs objIVs: objKeywords objKeywords: objMethodDict objMethodDict: objName objName: objSuperclassId objSuperclassId: objClass objClassId objClassId: allocateAnInstance offsetFromClassOfInstanceVariable: offsetFromObjectOfInstanceVariable: valueOfInstanceVariable: #send:withArguments: #super:withArguments:from: lookup: bodyOfMethod:)
]

{ #category : #'method management' }
Obj >> addMethod: aSelector args: aString withBody: aStringBlock [ 
	"Define a method with selector <aSelector> , having a string representing the arguments (ie 'aNumber aStream') 
	and a string representing the method body in the receiver.
	If a method with the same selector already existed, the new definition will erase it.
	self is an objClass"

	self  objMethodDict at: aSelector put: (self methodWithHeader: aString andBody: aStringBlock).
	^self
]

{ #category : #'method management' }
Obj >> addUnaryMethod: aSelector withBody: aStringBlock [ 
	"Define a unary method with selector <aSelector> and a body <aaStringBlock> in the receiver.
	If a method with the same selector already existed, the new definition will erase it.
	self is an objClass"

	self  addMethod: aSelector args: '' withBody: aStringBlock
]

{ #category : #'instance allocation' }
Obj >> allocateAnInstance [
	"Returns a newly created instance of self, an ObjClass. In this implementation the identifier of the object class is the name of the class. "

	| size instance |
	size := self numberOfIVs.
	instance := Obj new: size.

	"Store the class-name symbol in the class offset"
	instance at: self offsetForClass put: self objName.

	"Initialize all other instance variables to nil"
	2 to: size do: [:i | instance at: i put: nil].

	^ instance
	
]

{ #category : #'message passing' }
Obj >> basicSend: selector withArguments: arguments from: aClass [
	"Execute the method found starting from aClass and whose name is selector."
	"The core of the sending a message, reused for both a normal send or a super one."
	
	| methodOrNil |
	methodOrNil := aClass lookup: selector.
	^ methodOrNil 
		ifNotNil: [ methodOrNil valueWithArguments: (Array with: self) , arguments ] 
		ifNil: [ self sendError: selector withArgs: arguments ] 
]

{ #category : #'method management' }
Obj >> blockArgsFrom: aCol [
	"self basicNew blockArgsFrom: ' abc def ghi '"	
	
	| col st |
	col := aCol findTokens: Character space.
	col := col copyWithout: ''.
	st := ''.
	col do: [ :each | st := st , ':', each ] separatedBy: [st := st, ' '].
	^ st
]

{ #category : #'method management' }
Obj >> bodyOfMethod: aSelector [
	"Return the method associated with the selector <aSelector> in the receiver.
	Return nil if the selector is not defined.  self is an objClass"

	^ self objMethodDict at: aSelector ifAbsent: [ nil ]
]

{ #category : #debugging }
Obj >> classDebug [
	"(self giveClassNamed: #ObjClass) classDebug"

	"(self giveClassNamed: #ObjSet) classDebug"

	ObjClassInspector basicInspect: self
]

{ #category : #'keyword management' }
Obj >> computeAndSetKeywords [
	"Compute the keywords of a given class.  As the class of an object should not be changed.
	 the keywords should note contain the keyword class. self is anObjClass"

	self objKeywords: (self generateKeywords: (self objIVs copyWithout: #class))
]

{ #category : #'iv inheritance' }
Obj >> computeNewIVFrom: superIVOrdCol with: localIVOrdCol [
	"Returns an ordered collection that is the union without duplicate of ivOfSuper and ivOrderedCollection.
	Important the order of the instance variable is conserved"

	| ivs |
	^superIVOrdCol isNil 
		ifTrue: [localIVOrdCol]
		ifFalse: 
			[ivs := superIVOrdCol asOrderedCollection copy.
			localIVOrdCol do: [:e | (ivs includes: e) ifFalse: [ivs add: e]].
			ivs]
]

{ #category : #'iv inheritance' }
Obj >> computeNewIVFromClass: anObjClass with: ivOrderedCollection [ 
	"Obj computeNewIVFromClass: #(#C #C #O #(a b c d)) with: #(a z b t) asOrderedCollection"

	| ivs |
	^anObjClass isNil
		ifTrue: [ivOrderedCollection]
		ifFalse: 
			[ivs := anObjClass objIVs asOrderedCollection copy.
			ivOrderedCollection do: [:e | (ivs includes: e) ifFalse: [ivs add: e]].
			ivs]
]

{ #category : #'method management' }
Obj >> doesUnderstand: aSelector [ 
	"Tell if the receiver has a method having <aSelector> as selector. self is anObjClass"

	^self objMethodDict keys includes: aSelector
]

{ #category : #'keyword management' }
Obj >> generateKeywords: anArray [ 
	"Returns an array containing the keywords made from the collection of Symbol passed as argument"
	"self new generateKeywords: #(titi toto lulu) "

	^anArray collect: [:e | (e , ':') asSymbol]
]

{ #category : #'instance initialization' }
Obj >> initializeUsing: anAlternatedArray [ 
	"Returns the receiver an ObjObject initialized according to the directives given by anAlternateArray"

	| ivValues |
	ivValues := self 
						returnValuesFrom: anAlternatedArray
						followingSchema: self objClass objKeywords.
	1 to: ivValues size do: [:i | 
        | value |
        value := ivValues at: i.
        
        "Special handling for sharedVariables (slot 7 corresponds to keyword position 6)"
        (i = 6 and: [value notNil]) 
            ifTrue: [self at: i + 1 put: value asOrderedCollection]
            ifFalse: [self at: i + 1 put: value]
    ].
	^ self 
]

{ #category : #'keyword management' }
Obj >> keywordValue: aSymbol getFrom: anArray ifAbsent: aDefaultValue [ 
	"precondition: ((length anArray) mod 2) = 0 
	returns the value associated with the keyword represented by aSymbol 
	in the initarg list represented by anArray."

	"self new keywordValue: #titi getFrom: #(toto 12 titi 23) ifAbsent: 2"
	"self new keywordValue: #titi getFrom: #(toto 23) ifAbsent: 2"

	| i |
	i := anArray indexOf: aSymbol ifAbsent: nil.
	^i isNil 
		ifTrue: [aDefaultValue] 
		ifFalse: [anArray at: i + 1]
]

{ #category : #'method lookup' }
Obj >> lookup: selector [
	"look for the method named <selector> starting in the receiver. 
	The lookup is done for a message sent to <anObjObject>. self is an objClass"
	
	| method |
	
	method := self bodyOfMethod: selector.
	
	^ method 
		ifNotNil: [ "method found" method ]
		ifNil: [ 
			(self objName == #ObjObject)
				ifTrue: [ "hierarchy root reached, method not found" nil ]
				ifFalse: [ self objSuperclass lookup: selector ] 
		]

]

{ #category : #'method management' }
Obj >> methodWithHeader: col andBody: aString [

	| block string resBlock |
	string := self stringOfBlockBodyFromHeader: col andBody: aString.
	block := OpalCompiler new
		         source: string;
		         evaluate.

	"bind superclass to the superclass of the class defining the method"
	resBlock := block value:
		            (Obj
			             giveClassNamed: self objSuperclassId
			             ifAbsent: [ 666 ]).
	^ resBlock
]

{ #category : #'iv management' }
Obj >> numberOfIVs [
	"Returns the number of instance variables of the class an ObjClass"

	^self objIVs size
]

{ #category : #'object structure primitive' }
Obj >> objClass [
	"Receiver should be: anObjObject. Returns the class of the receiver (which is an ObjObject) and not its internal identification. Differs from classId  which is a primitive to access the structure representing a class"

	^ Obj giveClassNamed: (self objClassId)
]

{ #category : #'object structure primitive' }
Obj >> objClassId [
	"Receiver should be: anObjObject. Returns the identifier that identifies the class of the receiver (an objObject). In this implementation we chose to use the class name as identifier"

	^ self at: self offsetForClass 
]

{ #category : #'object structure primitive' }
Obj >> objClassId: anObjClassId [
	"Receiver should be: anObjObject. Set the identifier that identifies the class of the receiver (anObjObject)."

	^ self at: self offsetForClass put: anObjClassId 
]

{ #category : #'class structure primitive' }
Obj >> objIVs [
	"Receiver should be: anObjClass. Returns the list of instance variables"

	^ self at: self offsetForIVs 
]

{ #category : #'class structure primitive' }
Obj >> objIVs: anOrderedCollection [
	"Receiver should be: anObjClass. Set the list of instance variable names of the receiver (anObjClass)"

	^ self at: self offsetForIVs put: anOrderedCollection  
]

{ #category : #'class structure primitive' }
Obj >> objKeywords [
	"Receiver should be: anObjClass. Returns the keyword list of the receiver (anObjClass)"

	^ self at: self offsetForKeywords 
]

{ #category : #'class structure primitive' }
Obj >> objKeywords: anOrderedCollection [
	"Receiver should be: anObjClass. Sets the list of keywords of the receiver (anObjClass). Note that this method is just an accessor and does not compute the actual list of keywords"

	^ self at: self offsetForKeywords put: anOrderedCollection 
]

{ #category : #'class structure primitive' }
Obj >> objMethodDict [
	"Receiver should be: anObjClass. Returns the method dictionary of the receiver (anObjClass)"

	^ self at: self offsetForMethodDict 
]

{ #category : #'class structure primitive' }
Obj >> objMethodDict: aDictionary [
	"Receiver should be: anObjClass. Sets the method dictionary of the receiver (anObjClass)"

	^ self at: self offsetForMethodDict put: aDictionary 
]

{ #category : #'class structure primitive' }
Obj >> objName [
	"Receiver should be: anObjClass. Returns the name of the receiver (anObjClass)"

	^ self at: self offsetForName 
]

{ #category : #'class structure primitive' }
Obj >> objName: aName [
	"Receiver should be: anObjClass. Set the name of the receiver (anObjClass)"

	^ self at: self offsetForName put: aName 
]

{ #category : #'class structure primitive' }
Obj >> objSharedVariables [
	"Receiver should be: anObjClass. Returns the shared varibales dictionary of the receiver (anObjClass)"

	^ self at: self offsetForSharedVariables 
]

{ #category : #'class structure primitive' }
Obj >> objSharedVariables: aCollection [
	"Receiver should be: anObjClass. Sets the shared variables collection of the receiver (anObjClass)"

	^ self at: self offsetForSharedVariables put: aCollection 
]

{ #category : #'class structure primitive' }
Obj >> objSuperclass [
	"Receiver should be: anObjClass. Returns the superclass of the receiver (which is an objClass) and not its internal identification. Differs from superclassId which is a primitive to access the structure representing a class"

	^Obj giveClassNamed: self objSuperclassId
]

{ #category : #'class structure primitive' }
Obj >> objSuperclassId [
	"Receiver should be: anObjClass. Returns the superclass id of the receiver (anObjClass)"

	^ self at: self offsetForSuperclass 
]

{ #category : #'class structure primitive' }
Obj >> objSuperclassId: anObjClassId [
	"Receiver should be: anObjClass. Set the superclass id of the receiver (anObjClass)"

	^ self at: self offsetForSuperclass put: anObjClassId 
]

{ #category : #'object structure offset' }
Obj >> offsetForClass [

	^1
]

{ #category : #'class structure offset' }
Obj >> offsetForIVs [

	^4
]

{ #category : #'class structure offset' }
Obj >> offsetForKeywords [

	^5
]

{ #category : #'class structure offset' }
Obj >> offsetForMethodDict [

	^6
]

{ #category : #'class structure offset' }
Obj >> offsetForName [

	^2
]

{ #category : #'class structure offset' }
Obj >> offsetForSharedVariables [

	^7
]

{ #category : #'class structure offset' }
Obj >> offsetForSuperclass [

	^3
]

{ #category : #'iv management' }
Obj >> offsetFromClassOfInstanceVariable: aSymbol [
	"Returns the index of the instance variable named aSymbol for an class anObjClass.
	Returns 0 if the aSymbol is not present in the instance variable lists of anObjClass"

	| ivs |
	ivs := self objIVs.
	^ ivs indexOf: aSymbol ifAbsent: [ 0 ]
]

{ #category : #'iv management' }
Obj >> offsetFromObjectOfInstanceVariable: aSymbol [
	| index | 
	index := self objClass offsetFromClassOfInstanceVariable: aSymbol.
	(index = 0) ifTrue: [ self error: 'Unexistant instance variable', aSymbol, 'for', self asString ] 		ifFalse: [ ^index ]
]

{ #category : #printing }
Obj >> printOn: aStream [

	aStream nextPutAll: 'an Obj object: '.	
	super printOn: aStream
]

{ #category : #'method management' }
Obj >> removeMethod: aSelector [
	"Remove the method with aSelector <aSymbol> in the receiver. 
	self is an objClass"

	self objMethodDict removeKey: aSelector ifAbsent: [].
	^self
]

{ #category : #'keyword management' }
Obj >> returnValuesFrom: anInitargArray followingSchema: anArrayOfKeywords [ 
	"Return the values associated with the keys. The extracted values are taken from <anInitargArray> 
	and the return values are extracted according to the schema defined by the collection of keys <anArrayOfKeywords>"

	"self new returnValuesFrom: #(lulu 22  titi 35)  followingSchema: #(titi toto lulu titi)  #(35 nil 22 35)"

	^anArrayOfKeywords collect: 
			[:e | 
			self keywordValue: e
				getFrom: anInitargArray 
				ifAbsent: nil]
]

{ #category : #'message passing' }
Obj >> send: selector withArguments: arguments [
	"send the message whose selector is <selector> to the receiver. The arguments of the messages are an array <arguments>. The method is lookep up in the class of the receiver. self is an objObject or a objClass."

	^ self basicSend: selector withArguments: arguments from: self objClass
]

{ #category : #'message passing' }
Obj >> sendError: selector withArgs: arguments [
	"send error wrapping arguments into an array with the selector as first argument. Instead of an array we should create a message object."
	
	^ self send: #error withArguments: {(arguments copyWithFirst: selector)}
	

]

{ #category : #'method management' }
Obj >> stringOfBlockBodyFromHeader: col andBody: aString [ 
	^ '[ :superClassOfClassDefiningTheMethod |
		[ :objself ' , (self blockArgsFrom: col) , ' |
					 ' , aString , '] ]'
]

{ #category : #'message passing' }
Obj >> super: selector withArguments: arguments from: aSuperclass [
	"Invoke an oveeriden method named <selector> with an array of arguments <arguments>.  self is an objClass. aSuperclass should be the superclass of the class containing the method using super"

	^ self basicSend: selector withArguments: arguments from: aSuperclass 
]

{ #category : #'message passing' }
Obj >> superFrom: aSuperClass [
    "Automatically captures selector and arguments from context to prevent modification"
    | context selector argsArray numArgs sendContext |
    
    context := thisContext sender.
    
    "Find the closure context (the ObjVlisp method)"
    [context notNil] whileTrue: [
        (context closure notNil and: [context closure numArgs > 1]) ifTrue: [
            "Found the method closure - extract arguments"
            numArgs := context closure numArgs - 1. "Subtract objself"
            argsArray := Array new: numArgs.
            2 to: context closure numArgs do: [:i |
                argsArray at: i - 1 put: (context tempAt: i)
            ].
            
            "Find the selector from the send:withArguments: call"
            sendContext := context sender.
            [sendContext notNil] whileTrue: [
                (sendContext method selector == #send:withArguments: or: [
                 sendContext method selector == #basicSend:withArguments:from:]) ifTrue: [
                    "The selector is the first argument"
                    selector := sendContext tempAt: 1.
                    
                    ^ self super: selector withArguments: argsArray from: aSuperClass
                ].
                sendContext := sendContext sender
            ].
        ].
        context := context sender
    ].
    
    self error: 'Could not find selector in send context'
]

{ #category : #'iv management' }
Obj >> valueOfInstanceVariable: aSymbol [
	^ self at: (self offsetFromObjectOfInstanceVariable: aSymbol)
]
