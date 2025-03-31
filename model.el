(declare-datatypes () ((Type
						 (invalid-type)
						 (root)
						 (CharacterBody2D)
						 (Node)
						 (float)
						 (int)
						 (bool))))

(define-fun superclass ((x Type)) Type
			(if (= x float) root
			  (if (= x Node) root
				(if (= x CharacterBody2D) Node
				  root))))

(define-fun subtype ((x Type) (y Type)) Bool
			(or
			  (= x y)
			  (= (superclass x) y)
			  (= (superclass (superclass x)) y)
			  (= (superclass (superclass (superclass x))) y)))

(define-fun downcast-type ((x Type) (to Type)) Type
			(if (subtype to x) to invalid-type))

(assert (subtype float root))
(assert (subtype Node root))
(assert (subtype CharacterBody2D Node))
(assert (subtype CharacterBody2D root))

(declare-datatypes () ((Command
						 (store)
						 (increment))))

(declare-datatypes ((Signature 0))
				   (((TypeSig (t Type))
					 (CommandSig (cmd Command) (cmd_t Type)))))

(define-fun compatible ((s1 Signature) (s2 Signature)) Bool
			(or
			  (and (and ((_ is CommandSig) s1) ((_ is CommandSig) s2))
				   (= (cmd s1) (cmd s2))
				   (subtype (cmd_t s1) (cmd_t s2)))
			  (and (and ((_ is TypeSig) s1) ((_ is TypeSig) s2))
				   (subtype (t s1) (t s2)))))

; --> float
(declare-const c1_o Signature)
(assert (= c1_o (TypeSig float)))

; * --> store(*)
(declare-const c2_i Signature)

(declare-const c2_o Signature)
(assert ((_ is CommandSig) c2_o))
(assert (= (cmd c2_o) store))
(assert (= (t c2_i) (cmd_t c2_o)))

; store(float) --> float
(declare-const c3_i Signature)
(assert (= c3_i (CommandSig store float)))

(declare-const c3_o Signature)
(assert (= c3_o (TypeSig float)))


; connections
(assert (compatible c1_o c2_i))
(assert (subtype (t c2_i) (t c1_o)))
(assert (compatible c2_o c3_i))


; CharacterBody2D
(declare-const c4_o Signature)
(assert (compatible c4_o (TypeSig CharacterBody2D)))

; Node
(declare-const c5_i Signature)
(assert (compatible c5_i (TypeSig Node)))

(assert (compatible c4_o c5_i))

(check-sat)
(get-model)
