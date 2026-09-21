# Lattice Color Hunt

> **「在材料科學中，完美的晶格往往是單調乏味的，而正是那些大大小小的晶體缺陷，賦予了材料獨特的物理性質與璀璨的色彩。」**
> 
> *"In materials science, perfect lattices are often monotonous and boring, and it is those very crystal defects, large and small, that endow materials with unique physical properties and brilliant colors."*

---

## 專案簡介 / Project Overview

**Lattice Color Hunt** 是「行動載具應用程式設計入門」課程中我的人機協作專案。我將材料科學中抽象的微觀晶格與晶體缺陷概念，轉化為一場結合科普教育與視覺尋寶的趣味小遊戲。

**Lattice Color Hunt** is a human-AI collaborative project developed for the mobile application design course. It transforms the abstract concepts of micro-lattices and crystal defects into an entertaining mini-game combining science education with visual treasure hunting.

---

## 遊戲玩法與流程 / Gameplay & App Flow

1. **Home View**：簡約美觀的入口介面，可以選擇難度並點擊按鈕，化身「小小科學家」展開探索。  
   *(A clean entry interface to select difficulty and step into the shoes of a "little scientist".)*
2. **Loading View**：隨機載入一項晶體系統與實用的材料科學小知識（例如寶石顏色與缺陷的關係）。  
   *(Randomly loads a crystal system along with practical materials science trivia.)*
3. **Countdown**：3、2、1 倒數計時，集中注意力準備進入微觀世界。  
   *(A 3, 2, 1 countdown to help players focus before entering the microscopic world.)*
4. **Game View**：在整齊排列的晶格網格中，尋找那些因為「晶體缺陷」而綻放出不同色彩的目標點。  
   *(Search through neatly arranged lattice grids to find target points exhibiting distinct colors due to crystal defects.)*
5. **Result View**：統計找出的缺陷數量與花費時間，解鎖科學家專屬評語與成就！  
   *(Summarizes the results, unlocking scientist-exclusive evaluations and achievements!)*

---

## AI 協同開發亮點 / AI-Assisted Development Highlights

因應開發環境的額度限制，本專案採取了**網格化 Prompt 策略**：  
*To adapt to development quota limitations, this project adopted a **Structured Prompt Strategy**：*

- 先在外部 AI 介面中，將抽象的遊戲邏輯（首頁、科普過場、倒數、遊戲主軸、結算）逐步梳理成結構化指令。  
  *(Structured abstract game logic into clear instructions using external AI interfaces.)*
- 再帶回 Xcode 中進行實作與除錯，實現流暢的人機協作開發流程。  
  *(Brought prompts back into Xcode for implementation and debugging, achieving a seamless collaborative workflow.)*
