#!/usr/bin/env python3
"""
A silly "error calculator" 

Run: python error_calculator.py

DISCLAIMER: This program deliberately creates and catches exceptions. It does
NOT perform any destructive actions (no file deletion, no networking, no
hardware access). Use for learning and fun  (◕‿◕✿)
"""

import random
import traceback


def add(num1, num2):
    return num1 + num2


def subtract(num1, num2):
    return num1 - num2


def multiply(num1, num2):
    return num1 * num2


def divide(num1, num2):
    if num2 == 0:
        raise ZeroDivisionError("division by zero from divide()")
    return num1 / num2


# --- Error triggers -------------------------------------------------
# Each trigger is a callable that will (intentionally) raise one or more
# exceptions. The driver code will execute them inside try/except so the
# program can continue and report on each exception


def trigger_type_error():
    return 'a' + 5  # TypeError   #type: ignore


def trigger_value_error():
    # invalid literal for int()
    return int('not-an-int')  # ValueError


def trigger_index_error():
    lst = [1, 2, 3]
    return lst[10]  # IndexError


def trigger_key_error():
    d = {'x': 1}
    return d['missing']  # KeyError


def trigger_attribute_error():
    x = 10
    return x.nope  # AttributeError   #type: ignore


def trigger_zero_division_error():
    return 1 / 0  # ZeroDivisionError


def trigger_name_error():
    # reference an undefined name
    return undefined_variable  # NameError   #type: ignore


def trigger_syntax_error():
    # execute invalid Python source
    exec('def broken(:\n    pass')  # SyntaxError when exec() parses


def trigger_import_error():
    # import a non-existent module
    __import__('this_module_does_not_exist_12345')  # ModuleNotFoundError


def trigger_recursion_error():
    def recurse():
        return recurse()
    recurse()  # likely causes RecursionError


def trigger_memory_error():
    # Explicitly raise MemoryError (safe)
    # Do NOT actually allocate huge memory.
    # It's against my religion ͡° ͜ʖ ͡°
    raise MemoryError('simulated out-of-memory for demo')


def trigger_runtime_error():
    raise RuntimeError('simulated runtime problem')


def trigger_stop_iteration():
    it = iter([])
    return next(it)  # StopIteration


def trigger_os_error():
    # Try opening a non-existent file to get FileNotFoundError (subclass of OSError)
    open('/file/that/does/not/exist/___I_exist_in_her_dreams_ha.ha___')


def trigger_keyboard_interrupt():
    # Simulate a KeyboardInterrupt without actually requiring user input
    raise KeyboardInterrupt('simulated Ctrl-C')


def trigger_system_exit():
    # Will normally exit; raise and catch it in the driver
    raise SystemExit('simulated exit')


def trigger_overflow_error():
    # Force an arithmetic overflow in older Python builds or explicitly raise
    raise OverflowError('simulated overflow')


def trigger_lookup_error():
    # Base class for IndexError/KeyError; raise directly
    raise LookupError('simulated lookup error')


def trigger_assertion_error():
    assert False, 'simulated assertion failure'


ERROR_TRIGGERS = {
    'TypeError': trigger_type_error,
    'ValueError': trigger_value_error,
    'IndexError': trigger_index_error,
    'KeyError': trigger_key_error,
    'AttributeError': trigger_attribute_error,
    'ZeroDivisionError': trigger_zero_division_error,
    'NameError': trigger_name_error,
    'SyntaxError': trigger_syntax_error,
    'ImportError': trigger_import_error,
    'RecursionError': trigger_recursion_error,
    'MemoryError': trigger_memory_error,
    'RuntimeError': trigger_runtime_error,
    'StopIteration': trigger_stop_iteration,
    'OSError': trigger_os_error,
    'KeyboardInterrupt': trigger_keyboard_interrupt,
    'SystemExit': trigger_system_exit,
    'OverflowError': trigger_overflow_error,
    'LookupError': trigger_lookup_error,
    'AssertionError': trigger_assertion_error,
}


# ---------------- utils ----------------------
def run_trigger(name, func):
    """Run a trigger and capture the exception traceback (if any)."""
    try:
        result = func()

    except BaseException as e:
        tb = traceback.format_exc()
        return {'name': name, 'exception': e, 'traceback': tb}
    
    else:
        return {'name': name, 'result': result}


def run_all_triggers(report_success=True):
    """Run every trigger and print a summary report."""
    results = []
    for name, func in ERROR_TRIGGERS.items():
        print(f'--> Running trigger: {name}')
        res = run_trigger(name, func)
        results.append(res)
        if 'exception' in res:
            print(f'    -> Exception caught: {type(res["exception"]).__name__}: {res["exception"]}')
        else:
            if report_success:
                print(f'    -> Completed (no exception). Result: {res["result"]!r}')
    return results


def random_error_roulette(n=5):
    """Run n random error triggers (may repeat)."""
    names = list(ERROR_TRIGGERS.keys())
    chosen = random.choices(names, k=n)
    print(f'Running roulette: {chosen}')
    return [run_trigger(name, ERROR_TRIGGERS[name]) for name in chosen]

# ---------------- Interactive CLI ----------------------
def print_menu():
    print('\n=== Error Calculator ===')
    print('1) Run all error triggers (safe: exceptions are caught)')
    print('2) Trigger a specific error by name (e.g. TypeError)')
    print('3) Random error roulette')
    print('4) Use normal calculator functions (may raise ZeroDivisionError)')
    print('5) Exit')


def main():
    while True:
        print_menu()
        choice = input('Choose an option: ').strip()

        if choice == '1':
            run_all_triggers()

        elif choice == '2':
            name = input('Enter error name (or blank to list): ').strip()
            if not name:
                print('Available:', ', '.join(sorted(ERROR_TRIGGERS.keys())))
                continue
            func = ERROR_TRIGGERS.get(name)

            if not func:
                print('Unknown trigger name. Try again.')
                continue
            res = run_trigger(name, func)

            if 'exception' in res:
                print(f'Caught {type(res["exception"]).__name__}: {res["exception"]}')
            
            else:
                print('No exception raised. Result:', res['result'])

        elif choice == '3':
            try:
                n = int(input('How many random triggers? (default 5): ') or '5')

            except ValueError:
                n = 5
            random_error_roulette(n)

        elif choice == '4':
            # demo that can still raise ZeroDivisionError / TypeError
            try:
                a = input('First operand (e.g. 67 or "biscuits"): ')
                b = input('Second operand: ')

                # try to interpret as int when possible
                try:
                    a_eval = int(a)

                except Exception:
                    a_eval = a

                try:
                    b_eval = int(b)
        
                except Exception:
                    b_eval = b      
                op = input('Operation (+, -, *, /): ').strip()
                ops = {'+': add, '-': subtract, '*': multiply, '/': divide}
                
                if op not in ops:
                    print('Unknown operation')
                    continue

                fn = ops[op]
                print('Result:', fn(a_eval, b_eval))

            except Exception as e:
                print(f'Calculator raised {type(e).__name__}: {e}')

        elif choice == '5':
            print('Au revoir darling!')
            break

        else:
            print('◔̯◔\nPlease choose a valid option.')


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('\n﴾͡๏̯͡๏﴿ ORLY?\nInterrupted by user. Exiting.')
        
    except SystemExit as se:
        print(f'Program requested exit: {se}')

    except Exception as e:
        print('Unhandled exception in main loop:', type(e).__name__, e)
        print('This was not part of the plan. I think.')
        print(traceback.format_exc())

