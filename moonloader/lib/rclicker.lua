--Библиотека RenderClicks

function clickBox(posX, posY, sizeX, sizeY, color, colorA)
   renderDrawBox(posX, posY, sizeX, sizeY, color)
   local curX, curY = getCursorPos()
   if curX >= posX and curX <= posX + sizeX and curY >= posY and curY <= posY + sizeY then
     renderDrawBox(posX, posY, sizeX, sizeY, colorA)
     if wasKeyPressed(1) then
       return true
     end
   end
end

function clickBoxWB(posX, posY, sizeX, sizeY, color, colorA, border, colorB, colorC)
   renderDrawBoxWithBorder(posX, posY, sizeX, sizeY, color, border, colorB)
   local curX, curY = getCursorPos()
   if curX >= posX and curX <= posX + sizeX and curY >= posY and curY <= posY + sizeY then
     renderDrawBox(posX, posY, sizeX, sizeY, colorA,border, colorC)
     if wasKeyPressed(1) then
       return true
     end
   end
end

function clickText(font, text, posX, posY, color, colorA)
   renderFontDrawText(font, text, posX, posY, color)
   local textLenght = renderGetFontDrawTextLength(font, text)
   local textHeight = renderGetFontDrawHeight(font)
   local curX, curY = getCursorPos()
   if curX >= posX and curX <= posX + textLenght and curY >= posY and curY <= posY + textHeight then
     renderFontDrawText(font, text, posX, posY, colorA)
     if wasKeyPressed(1) then
       return true
     end
   end
end
