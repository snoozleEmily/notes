def first():
    print('Function first was called')
    
def second():
    print('Function second was called')
    
def third():
    first()
    second()    
    raise NotImplementedError("You need to implement this function.")

third()