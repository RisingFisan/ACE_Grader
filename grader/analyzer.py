import clang.cindex as cindex

"""
"Program uses recursion" => 1
"Program uses loops" => 2
"Program uses pointers" => 3
"Program uses dynamic memory" => 4
"Program frees allocated memory" => 5
"Function X is used" => 10
"Function X is recursive" => 11
"Function X is iterative" => 12
"Function X uses pointers" => 13
"Function X uses dynamic memory" => 14
"Function X frees allocated memory" => 15
"""

def run_checks(params):
    index = cindex.Index.create()
    tu = index.parse('sub.c')
    root_cursor = tu.cursor

    for param in params:
        param['result'] = False

    for child in root_cursor.get_children():
        if child.location.file.name != 'sub.c':
            # This is a system header, skip it
            continue
        elif child.kind == cindex.CursorKind.FUNCTION_DECL:
            # print(f"**Function**: {child.spelling}\n")
            
            for param in params:
                match param['key']:
                    case 1:
                        param['result'] = param['result'] or is_recursive(child, child.spelling)
                    case 2:
                        param['result'] = param['result'] or uses_loops(child)
                    case 3:
                        param['result'] = param['result'] or uses_pointers(child)
                    case 4:
                        param['result'] = param['result'] or uses_dynamic_memory(child)
                    case 5:
                        param['result'] = param['result'] or frees_dynamic_memory(child)
                    case _:
                        if param['value'] == child.spelling:
                            match param['key'] % 10:
                                case 0:
                                    param['result'] = True
                                case 1:
                                    param['result'] = is_recursive(child, child.spelling)
                                case 2:
                                    param['result'] = uses_loops(child)
                                case 3:
                                    param['result'] = uses_pointers(child)
                                case 4:
                                    param['result'] = uses_dynamic_memory(child)
                                case 5:
                                    param['result'] = frees_dynamic_memory(child)
                                case _:
                                    pass

    return params
    
def is_recursive(cursor, function_name):
    if cursor.kind == cindex.CursorKind.CALL_EXPR and cursor.spelling == function_name:
        return True
    for child in cursor.get_children():
        if is_recursive(child, function_name):
            return True
    return False

def uses_loops(cursor):
    if cursor.kind == cindex.CursorKind.FOR_STMT or cursor.kind == cindex.CursorKind.WHILE_STMT:
        return True
    for child in cursor.get_children():
        if uses_loops(child):
            return True
    return False

def uses_pointers(cursor):
    if (cursor.kind == cindex.CursorKind.PARM_DECL or cursor.kind == cindex.CursorKind.VAR_DECL) and cursor.type.kind == cindex.TypeKind.POINTER:
        return True
    for child in cursor.get_children():
        if uses_pointers(child):
            return True
    return False

def uses_dynamic_memory(cursor):
    if cursor.kind == cindex.CursorKind.CALL_EXPR and cursor.spelling in ('malloc','calloc','realloc'):
        return True
    for child in cursor.get_children():
        if uses_dynamic_memory(child):
            return True
    return False

def frees_dynamic_memory(cursor):
    if cursor.kind == cindex.CursorKind.CALL_EXPR and cursor.spelling == 'free':
        return True
    for child in cursor.get_children():
        if frees_dynamic_memory(child):
            return True
    return False