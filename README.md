# HiddenApp

A tiny menu bar utility for **macOS 27** that hides the icons of other apps behind a separator, and shows them again with one click.

[Русская версия ниже ↓](#русская-версия)

```
[hidden icons]  |  >  [icons that stay visible]  [system icons, clock]
```

Everything to the **left** of `|` is hidden. Click `>` to show it, and it hides itself again after a few seconds.

> **Heads up:** macOS 27 changed how the menu bar is drawn, so the classic "stretch a separator" trick used by Hidden Bar no longer works. This app uses an **undocumented** macOS mechanism instead (see [Limitations](#limitations)). It will not be accepted into the Mac App Store and may stop working after a macOS update.

## Features

- Hide only the icons you choose, by placing them to the left of the separator `|`
- One click on the arrow shows or hides them
- Auto-hide timer: Never, 5 s, 8 s, 15 s, 30 s or 1 minute
- Launch at login
- English and Russian interface

## Requirements

- macOS 27
- **Accessibility** permission (the app reads where each menu bar icon sits, so it knows what is left of the separator)
- The app must be located in the **Applications** folder. macOS hides the menu bar icons of apps launched from anywhere else, including this app's own icons.

## Installation

1. Download the latest `.dmg` from the [Releases](../../releases) page.
2. Open it and drag the app into **Applications**.
3. Launch it from **Applications**. If macOS says it cannot verify the developer, see [If macOS blocks the app](#if-macos-blocks-the-app).
4. Grant **Accessibility** access: *System Settings → Privacy & Security → Accessibility*.

## Usage

1. Hold **⌘ (Command)** and drag the icons you want to hide to the **left** of `|`. Keep `|` to the left of `>`.
2. Click `>` to show the hidden icons, or click it again to hide them right away.
3. Click `|` to open the settings menu: launch at login, auto-hide timer, quit.

Tip: to rearrange icons, set the timer to **Never** first. Icons cannot be moved while they are hidden.

## If macOS blocks the app

The app is not signed with an Apple Developer ID and is not notarized, so macOS may refuse to open it the first time.

1. Try to open the app once.
2. Go to *System Settings → Privacy & Security*, scroll down to the message about the app and click **Open Anyway**.
3. Confirm. The app will open normally from then on.

## Limitations

- Works only on **macOS 27**.
- Hiding relies on a **private, undocumented** part of macOS (the menu bar visibility restriction behind assessment mode). Apple can change or remove it in any update; if that happens the app will stop hiding icons until it is updated.
- While icons are hidden, macOS may ignore clicks on some system items such as the clock or Control Center. Show the icons first, then click.
- System icons (clock, Wi-Fi, sound, Control Center, battery) are meant to stay visible; only the icons of other apps are hidden.
- The app is not sandboxed and cannot be distributed through the Mac App Store.
- After you replace the app with a new version, macOS may forget the Accessibility permission. Remove the old entry with **−** in *Privacy & Security → Accessibility* and add the app again.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| Nothing gets hidden | Check that the app is in **Applications**, has Accessibility access, and that the icons are to the left of `\|`, which itself is to the left of `>` |
| A message says to launch from Applications | Move the app to **Applications** and launch it from there, not from Xcode or the disk image |
| Icons cannot be dragged | Set the timer to **Never**, show the icons with `>`, then drag with ⌘ held |
| The app's own icons disappear | The app is running outside **Applications** |

## Build from source

1. Open the project in Xcode.
2. Set the minimum deployment target to **macOS 27.0**.
3. Remove the **App Sandbox** capability (*Signing & Capabilities*).
4. Build with the **Release** configuration, then copy the app to **Applications**.

## Credits and disclaimer

Inspired by [Hidden Bar](https://github.com/dwarvesf/hidden). Not affiliated with Apple or with the Hidden Bar project. This is an experimental personal project provided as is, without warranty.

## License

MIT. See the `LICENSE` file.

---

# Русская версия

Небольшая утилита для строки меню **macOS 27**: прячет значки других программ за разделителем и показывает их одним нажатием.

```
[скрытые значки]  |  >  [значки, которые остаются]  [системные значки, часы]
```

Всё, что стоит **левее** `|`, скрывается. Нажмите `>`, чтобы показать значки: через несколько секунд они спрячутся снова.

> **Важно:** в macOS 27 строка меню устроена по-другому, поэтому привычный способ Hidden Bar (растягивание разделителя) больше не работает. Это приложение использует **недокументированный** механизм macOS (см. [Ограничения](#ограничения)). В Mac App Store такое приложение не примут, а после обновления macOS оно может перестать работать.

## Возможности

- Скрывает только те значки, которые вы поставили левее разделителя `|`
- Показать и скрыть значки можно одним нажатием на стрелочку
- Таймер автоскрытия: никогда, 5, 8, 15, 30 секунд или 1 минута
- Автозапуск при входе в систему
- Интерфейс на английском и русском

## Требования

- macOS 27
- Разрешение **Универсального доступа** (приложение определяет, где стоят значки в строке меню, чтобы понять, что левее разделителя)
- Приложение должно лежать в папке **«Программы»**. Если запустить его из другого места, macOS спрячет значки таких приложений, включая значки самой программы.

## Установка

1. Скачайте последний файл `.dmg` на странице [Releases](../../releases).
2. Откройте его и перетащите приложение в папку **«Программы»**.
3. Запустите приложение из «Программ». Если macOS пишет, что не может проверить разработчика, смотрите раздел [Если macOS блокирует приложение](#если-macos-блокирует-приложение).
4. Дайте доступ: *Системные настройки → Конфиденциальность и безопасность → Универсальный доступ*.

## Как пользоваться

1. Зажмите **⌘ (Command)** и перетащите значки, которые нужно скрывать, **левее** `|`. Разделитель `|` должен стоять левее `>`.
2. Нажмите `>`, чтобы показать скрытые значки, или нажмите ещё раз, чтобы спрятать их сразу.
3. Нажмите на `|`, чтобы открыть меню настроек: автозапуск, таймер автоскрытия, выход.

Совет: чтобы переставить значки, сначала выберите таймер **«Никогда»**. Скрытые значки двигать нельзя.

## Если macOS блокирует приложение

Приложение не подписано сертификатом Apple Developer ID и не нотаризовано, поэтому при первом запуске macOS может отказаться его открыть.

1. Попробуйте открыть приложение один раз.
2. Зайдите в *Системные настройки → Конфиденциальность и безопасность*, прокрутите вниз до сообщения о приложении и нажмите **«Всё равно открыть»**.
3. Подтвердите. Дальше приложение будет открываться как обычно.

## Ограничения

- Работает только на **macOS 27**.
- Скрытие опирается на **закрытую, недокументированную** часть macOS (ограничение видимости значков строки меню, которое лежит в основе экзаменационного режима). Apple может изменить или убрать её в любом обновлении. Тогда приложение перестанет скрывать значки, пока не выйдет обновление.
- Пока значки скрыты, macOS может не реагировать на нажатия по некоторым системным элементам, например по часам и Пункту управления. Сначала покажите значки, потом нажимайте.
- Системные значки (часы, Wi-Fi, звук, Пункт управления, батарея) должны оставаться на месте, скрываются только значки других приложений.
- Приложение работает без «песочницы» и не может распространяться через Mac App Store.
- После замены приложения новой версией macOS может «забыть» разрешение Универсального доступа. Удалите старую запись кнопкой **−** в *Конфиденциальность и безопасность → Универсальный доступ* и добавьте приложение заново.

## Если что-то не работает

| Проблема | Что делать |
| --- | --- |
| Ничего не скрывается | Проверьте, что приложение лежит в «Программах», у него есть доступ Универсального доступа, а значки стоят левее `\|`, который стоит левее `>` |
| Появляется сообщение «запустите из папки Программы» | Переместите приложение в «Программы» и запускайте оттуда, а не из Xcode или образа диска |
| Значки не перетаскиваются | Выберите таймер **«Никогда»**, покажите значки через `>`, затем перетаскивайте с зажатой ⌘ |
| Пропадают значки самого приложения | Приложение запущено не из «Программ» |

## Сборка из исходников

1. Откройте проект в Xcode.
2. Укажите минимальную версию macOS **27.0**.
3. Удалите возможность **App Sandbox** (*Signing & Capabilities*).
4. Соберите в конфигурации **Release** и скопируйте приложение в «Программы».

## Благодарности и отказ от ответственности

Вдохновлено [Hidden Bar](https://github.com/dwarvesf/hidden). Не связано с Apple и с проектом Hidden Bar. Это экспериментальный личный проект, который предоставляется «как есть», без гарантий.

## Лицензия

MIT. См. файл `LICENSE`.
