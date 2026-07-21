# Production typography + asset map

База проверки: production package `WS-14-production-dist.zip`, commit `bcf38d6`. Проверены заданные CSS, HTML-переносы и доступная ширина на 360/390/768/1024/1440 px. Эти правила заменяют текущую зависимость заголовков от `Impact` и ручных `<br>`.

## 1. Найденные риски переполнения

| Viewport | Доступный `.shell` | Проблемный узел | Причина | Исправление |
|---:|---:|---|---|---|
| 360 | 328 px | hero `Брендированная вода<br>в такси` | 54 px display + ручной `<br>`; длинное слово занимает почти всю строку, фраза распадается на 3 строки | hero 42 px, `max-inline-size: 10ch`, убрать `<br>`, разрешить перенос только по пробелам |
| 360 | 328 px | `.hero-actions .button` | 16 px текст + 50 px horizontal padding оставляют 278 px; длинный CTA близок к пределу | width 100%, padding-inline 16 px, font 15 px, `white-space: normal`, min-height 52 px |
| 360 | 328 px | `vodavtaxi@yandex.ru` | непрерывная строка; при zoom/смене font может выйти из колонки | `overflow-wrap:anywhere`, font 18–20 px |
| 390 | 358 px | hero h1 | текущий 58.5 px сохраняет риск третьей строки и визуально давит на CTA | hero 44 px; те же правила переноса |
| 390 | 358 px | `Для B2C-механик с понятной ценностью` | current h2 ≈50.7 px; узкая колонка даёт рваные 4–5 строк | h2 38 px, max 14ch, `text-wrap:balance` |
| 768 | 736 px | launch `От брифа до отчётности — 35–40 дней` | single-column h2 около 61 px; 3–4 неуправляемых строки | h2 52 px, max 16ch; обернуть `35–40 дней` в `white-space:nowrap` |
| 768 | 736 px | hero | mobile layout всё ещё использует 7.2vw = 55 px; headline слишком широк относительно будущей графики | 52 px, hero copy max 640 px, графика ниже с ratio 4/3 |
| 1024 | 984 px | hero copy ≈546 px | h1 ≈73.7 px; `Брендированная вода` не помещается как заданная строка | сетка `minmax(0, 1.08fr) minmax(340px,.92fr)`, gap 32; h1 64 px; без `<br>` |
| 1024 | 984 px | `.section-heading` средняя колонка ≈390 px | h2 ≈51 px; benefits/launch получают лишние переносы | на 901–1100 перейти на `2fr 5fr`, описание вынести следующей строкой либо h2 46 px |
| 1024 | 984 px | header nav + CTA | суммарная минимальная ширина близка к shell, длинные nav labels сжимают gaps | tablet breakpoint 1100 px: скрыть desktop nav, показать menu button |
| 1440 | 1240 px | hero copy ≈695 px | h1 достигает 103.7 px; заданная первая строка шире колонки | cap 88 px, max 11ch, без ручного break |
| 1440 | 1240 px | launch h2 в колонке ≈492 px | 72 px headline + длинный диапазон создают 4 строки | cap 64 px и max 15ch; диапазон не разрывать |

`overflow-x:hidden` на `body` не является исправлением: он маскирует выход текста. После внедрения временно заменить на `overflow-x:clip` и проверять `scrollWidth === clientWidth` для каждого viewport.

## 2. Implementation-ready CSS

```css
:root {
  --page-gutter: clamp(16px, 3.33vw, 48px);
  --content-max: 1240px;
  --copy-max: 64ch;
  --display-max: 16ch;
}

.shell {
  width: min(var(--content-max), calc(100% - 2 * var(--page-gutter)));
  margin-inline: auto;
}

.hero-grid,
.section-heading,
.split,
.terms-grid,
.contact-grid { min-width: 0; }

.hero-copy,
.hero-stage,
.section-heading > *,
.split > *,
.terms-grid > *,
.contact-grid > * { min-inline-size: 0; }

.hero h1 {
  max-inline-size: 11ch;
  font-size: clamp(2.625rem, 6.1vw, 5.5rem);
  line-height: .92;
  letter-spacing: -.025em;
  overflow-wrap: normal;
  word-break: normal;
  text-wrap: balance;
}

.section h2 {
  max-inline-size: var(--display-max);
  font-size: clamp(2.375rem, 4.45vw, 4rem);
  line-height: .98;
  overflow-wrap: normal;
  word-break: normal;
  text-wrap: balance;
}

.lead,
.section-copy p,
.contact-copy > p { max-inline-size: var(--copy-max); }

.direct-links a,
.button { overflow-wrap: anywhere; }

.nowrap { white-space: nowrap; }

@media (min-width: 901px) {
  .hero-grid {
    grid-template-columns: minmax(0, 1.08fr) minmax(340px, .92fr);
    gap: clamp(32px, 4vw, 56px);
  }
}

@media (max-width: 1100px) {
  .desktop-nav { display: none; }
  .menu-toggle { display: grid; }
  .section-heading { grid-template-columns: minmax(120px, 2fr) minmax(0, 5fr); }
  .section-heading > p:last-child { grid-column: 2; }
}

@media (max-width: 900px) {
  .hero-grid, .section-heading, .split, .terms-grid, .contact-grid { grid-template-columns: 1fr; }
  .section-heading > p:last-child { grid-column: auto; }
  .hero-copy { max-inline-size: 640px; }
  .hero-art { aspect-ratio: 4 / 3; min-height: 0; }
}

@media (max-width: 520px) {
  .hero h1 { font-size: clamp(2.625rem, 11.3vw, 2.75rem); max-inline-size: 10ch; }
  .section h2 { font-size: clamp(2.375rem, 10.25vw, 2.5rem); max-inline-size: 14ch; }
  .hero-actions .button { width: 100%; padding-inline: 16px; font-size: 15px; white-space: normal; }
  .direct-links a { font-size: clamp(1.125rem, 5vw, 1.25rem); }
}
```

### HTML-переносы

- Hero: заменить `<h1>Брендированная вода<br><em>в такси</em></h1>` на `<h1>Брендированная вода <em>в такси</em></h1>`.
- Launch: диапазон оформить `<em class="nowrap">35–40 дней</em>`.
- Не добавлять `<wbr>` в русские слова и email; для email использовать `overflow-wrap:anywhere`.
- Ручные `<br>` допустимы только выше 1100 px через отдельный `<span class="desktop-break">`; на меньших viewport `display:none` у break, а не у текста.

## 3. Локальный asset-map

Все композиции абстрактны, не изображают реальную бутылку/этикетку, не являются логотипом и не содержат продуктовых утверждений.

| Файл | Секция | Роль | Встраивание | Accessibility |
|---|---|---|---|---|
| `assets/voda-v-taxi/graphics/hero-route-composition.svg` | hero | главный визуальный маршрут: физическая точка → QR-grid → digital signal | `<img class="hero-art" ... width="960" height="760">` | декоративный: `alt=""`; смысл уже есть в hero copy |
| `assets/voda-v-taxi/graphics/mechanics-route.svg` | mechanics | непрерывная линия с четырьмя остановками | inline `<svg>` либо `<img width="1200" height="300">`; overlay под существующим `<ol>` | `aria-hidden="true"` при наличии текстового списка |
| `assets/voda-v-taxi/graphics/conversion-ripples.svg` | benefits/contact | расходящиеся кольца контакта и направленный signal | background/image, не выше 38% opacity | `aria-hidden="true"` / пустой alt |

### Размеры и поведение

- SVG хранить как исходные assets без raster variants; SVG имеет `viewBox`, не фиксировать CSS height без `aspect-ratio`.
- Hero: desktop `inline-size:min(100%,600px)`, tablet/mobile `inline-size:100%`, `aspect-ratio:24/19`, `object-fit:contain`.
- Mechanics: не растягивать stroke через CSS transform; `width:100%; height:auto`. На mobile повернуть композицию нельзя — использовать существующую CSS vertical route, SVG скрыть.
- Ripples: crop допустим через `object-fit:cover`; не размещать под длинным текстом без контрастной подложки.
- Цвета SVG привязаны к текущим `#14253a`, `#16bbd0`, `#f47a1f`, `#ddf6fa`; если палитра меняется, заменить значения внутри SVG одним проходом.

## 4. Acceptance matrix

- 360/390: hero headline 3 строки максимум; ни одно слово не режется; CTA и email внутри 328/358 px.
- 768: hero headline 2 строки максимум; graphic 4:3 под copy; launch title ≤3 строк.
- 1024: hero copy/graphic не перекрываются; desktop nav уже заменён mobile menu; headings не выходят из grid track.
- 1440: hero title ≤3 строки, максимум 88 px; launch range не разрывается; shell не шире 1240 px.
- Все viewport: `document.documentElement.scrollWidth === document.documentElement.clientWidth`; zoom 200%; long-text check с +30% длины; SVG не получают focus и не дублируют screen-reader content.

