# Создание пользователя Admin с паролем your_password 
net user Admin your_password /add

# Добавление пользователя Admin в группу Администраторы
net localgroup "Администраторы" Admin /add

# Снятие пользователя User из группы Администраторы (если он там есть)
try {
    Remove-LocalGroupMember -Group "Администраторы" -Member "User" -ErrorAction Stop
    Write-Host "Пользователь User удален из группы Администраторы"
} catch {
    Write-Host "Пользователь User не был в группе Администраторы или возникла ошибка"
}

# Добавление пользователя User в группу Пользователи
try {
    Add-LocalGroupMember -Group "Пользователи" -Member "User" -ErrorAction Stop
    Write-Host "Пользователь User добавлен в группу Пользователи"
} catch {
    Write-Host "Не удалось добавить пользователя User в группу Пользователи"
}

# Установка пароля your_password для пользователя User
try {
    $Password = ConvertTo-SecureString "your_password" -AsPlainText -Force
    Set-LocalUser -Name "User" -Password $Password -ErrorAction Stop
    Write-Host "Пароль для пользователя User успешно установлен"
} catch {
    Write-Host "Не удалось установить пароль для пользователя User"
}
