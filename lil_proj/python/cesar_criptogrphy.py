def _shift_letter(char, shift, encrypt=True):
    if not char.isalpha():
        return char
    
    ascii_base = 65 if char.isupper() else 97
    char_pos = ord(char) - ascii_base

    # Ignora se não estiver em A-Z/a-z
    if char_pos < 0 or char_pos >= 26:  
        return char
    
    new_pos = (char_pos + shift) % 26 if encrypt else (char_pos - shift) % 26
    return chr(new_pos + ascii_base)

def cifra_de_cesar(mensagem, deslocamento, criptografar=True):
    return ''.join(_shift_letter(char, deslocamento, criptografar) for char in mensagem)

exemplo_mensagem = "Segurança de Dados"
exemplo_deslocamento = 3
encrypted_exemplo = cifra_de_cesar(exemplo_mensagem, exemplo_deslocamento, criptografar=True)
decrypted_exemplo = cifra_de_cesar(encrypted_exemplo, exemplo_deslocamento, criptografar=False)

print("Exemplo:")
print(f"Mensagem original: {exemplo_mensagem}")
print(f"Mensagem criptografada (deslocamento {exemplo_deslocamento}): {encrypted_exemplo}")
print(f"Mensagem descriptografada: {decrypted_exemplo}\n")

# Entrada do usuário
mensagem = input("Digite a mensagem a ser criptografada: ")
deslocamento = int(input("Digite o valor do deslocamento (ex: 3): "))

encrypted = cifra_de_cesar(mensagem, deslocamento, criptografar=True)
decrypted = cifra_de_cesar(encrypted, deslocamento, criptografar=False)

print("\nResultado:")
print(f"Mensagem criptografada: {encrypted}")
print(f"Mensagem descriptografada: {decrypted}")