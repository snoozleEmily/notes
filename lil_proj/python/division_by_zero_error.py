def first():
    print('Function first was called')
    
def second():
    print('Function second was called')
    
def third(parr, parr2):
    first()
    second()    
    return parr / (parr2 - 10)

third(100, 10)
