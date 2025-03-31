from z3 import *

Type = Datatype('Type')
Type.declare('invalid_type')
Type.declare('root')
Type.declare('CharacterBody2D')
Type.declare('Node')
Type.declare('float')
Type.declare('int')
Type.declare('bool')
Type = Type.create()

def superclass(x):
    return If(x == Type.float, Type.root,
           If(x == Type.Node, Type.root,
           If(x == Type.CharacterBody2D, Type.Node,
              Type.root)))

def subtype(x, y):
    return Or(x == y,
              superclass(x) == y,
              superclass(superclass(x)) == y,
              superclass(superclass(superclass(x))) == y)

s = Solver()

s.add(subtype(Type.float, Type.root))
s.add(subtype(Type.Node, Type.root))
s.add(subtype(Type.CharacterBody2D, Type.Node))
s.add(subtype(Type.CharacterBody2D, Type.root))

Command = Datatype('Command')
Command.declare('store')
Command.declare('increment')
Command = Command.create()

Signature = Datatype('Signature')
Signature.declare('TypeSig', ('t', Type))
Signature.declare('CommandSig', ('cmd', Command), ('cmd_t', Type))
Signature = Signature.create()

def compatible(s1, s2):
    return Or(And(Signature.recognizer(1)(s1), Signature.recognizer(1)(s2),
                  Signature.cmd(s1) == Signature.cmd(s2),
                  Signature.cmd_t(s1) == Signature.cmd_t(s2)),
              And(Signature.recognizer(0)(s1), Signature.recognizer(0)(s2),
                  # subtype(Signature.t(s1), Signature.t(s2))))
                  Signature.t(s1) == Signature.t(s2)))

if True:
    # --> int
    c0_o = Const('c0_o', ArraySort(IntSort(), Signature))
    s.add(Select(c0_o, 0) == Signature.TypeSig(Type.int))

    # --> float
    c1_o = Const('c1_o', ArraySort(IntSort(), Signature))
    s.add(Select(c1_o, 0) == Signature.TypeSig(Type.float))

    # * -->
    c2_i = Const('c2_i', ArraySort(IntSort(), Signature))
    z = Int('z')
    y = Int('y')
    s.add(compatible(Select(c1_o, 0), Select(c2_i, z)))
    s.add(compatible(Select(c0_o, 0), Select(c2_i, y)))

    # --> store(*)
    c2_o = Const('c2_o', ArraySort(IntSort(), Signature))
    k = Int('k')
    l = Int('l')
    q = Int('q')
    s.add(ForAll([q],
        And(Signature.recognizer(1)(Select(c2_o, q)),
            Signature.cmd(Select(c2_o, q)) == Command.store)))
    s.add(Signature.t(Select(c2_i, z)) == Signature.cmd_t(Select(c2_o, l)))
    s.add(Signature.t(Select(c2_i, y)) == Signature.cmd_t(Select(c2_o, k)))

    # float -->
    c3_i = Const('c3_i', ArraySort(IntSort(), Signature))
    s.add(Select(c3_i, 0) == Signature.CommandSig(Command.store, Type.float))
    v = Int('v')
    s.add(Or(v == k, v == l))
    s.add(compatible(Select(c2_o, v), Select(c3_i, 0)))
else:
    # --> float
    c1_o = Const('c1_o', Signature)
    s.add(c1_o == Signature.TypeSig(Type.float))

    # * --> store(*)
    c2_i = Const("c2_i", Signature)

    c2_o = Const("c2_o", Signature)
    s.add(Signature.recognizer(1)(c2_o))
    s.add(Signature.cmd(c2_o) == Command.store)
    s.add(Signature.t(c2_i) == Signature.cmd_t(c2_o))

    # store(float) --> float
    c3_i = Const("c3_i", Signature)
    s.add(c3_i == Signature.CommandSig(Command.store, Type.float))

    c3_o = Const("c3_o", Signature)
    s.add(c3_o == Signature.TypeSig(Type.float))

    # connections
    s.add(compatible(c1_o, c2_i))
    s.add(compatible(c2_o, c3_i))

    # CharacterBody2D
    c4_o = Const("c4_o", Signature)
    s.add(compatible(c4_o, Signature.TypeSig(Type.CharacterBody2D)))

    # Node
    c5_i = Const("c5_i", Signature)
    s.add(compatible(c5_i, Signature.TypeSig(Type.Node)))

    s.add(compatible(c4_o, c5_i))

print(s.check())
print(s.model())

