# Virtualization/VBox

## Установка віртуалбокс. Робота з віртуальною машиною. 


### Налаштування параметрів віртуальної машини

![Параметри віртуальної машини]( Screenshots/TestVM.PNG)

### Тестування зрізу снепшоту
#### Створення папки та файла у цій папці. Створення снепшоту.
![Створення папки та файла цу цій папці. Створення снепшоту.]( Screenshots/TestSnapShot1.PNG)

#### Відновлення зрізу.
#### При відновленні зникла папка та файл в ньому.
![Створення папки та файла цу цій папці. Створення снепшоту.]( Screenshots/TestSnapShot2.PNG)


#### Збільшення розміру диску віртуальної машии VirtualBox
Знайдіть шлях до VBoxManage.exe: Зазвичай він знаходиться в папці встановлення VirtualBox (наприклад, C:\Program Files\Oracle\VirtualBox).
Відкрийте командний рядок:
Натисніть Win + R, введіть cmd і натисніть Enter.
Виконайте команду:
VBoxManage modifyhd "шлях_до_віртуального_диску.vdi" --resize новий_розмір_в_мегабайтах
Замініть шлях_до_віртуального_диску.vdi на фактичний шлях до вашого файлу віртуального диска, а новий_розмір_в_мегабайтах на бажаний розмір у мегабайтах.
Приклад:

VBoxManage modifyhd "D:\VIRTUALBOX\TestVM\TestVM.vdi" --resize 30000

![Зміна розміру диску віртуальної машини.]( Screenshots/resizeHddVdi.PNG)
#### Результат зміни розміру диска.
![Результат зміни розміру диску віртуальної машини.]( Screenshots/resizeHddVdiResult.PNG)
#### Команди як розширюють додаткоемісце призбільшенні віртуального диску у віртуальній машині у системі ubuntu.
#####sudo apt update
#####sudo apt install gparted
#####sudo parted -l
#####sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
#####sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
#####df -h
#### До розширення
![Перегляд файлової розмітки убунту]( Screenshots/HddAfterResize.PNG)
#### Після розширення
![Розширення вільного місця у убунту]( Screenshots/currentHddSize.PNG)

### Сттворення спільної папки у ubuntu ступу з windows
#### sudo apt update
#### sudo apt install samba
#### sudo chmod 777 /home/bald2003/ShareFolder 
### Для надання доступу до папки редагуемо файл 
##### sudo nano /etc/samba/smb.conf
#####[shared]
#####comment = опис_папки
#####path = /home/ваш_користувач/shared
#####browsable = yes
#####writable = yes
#####guest ok = yes
#####read only = no
#####create mask = 0777
#####directory mask = 0777

#Поки не вийшло розшарити для вынди папку в убунту. Ще буду гратися.

