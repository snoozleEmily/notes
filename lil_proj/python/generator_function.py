def first():         
    print('Function first was called')    
    yield     
    
def second():
    print('Function second was called')
    
def third():
    first()
    second()  
    
third()