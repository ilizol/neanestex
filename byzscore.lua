function read_json(filename)
    local file = io.open(filename, "r")
    if not file then return "{}" end
    local content = file:read("*all")
    file:close()
    return content
end

function parse_notes(filename)
    local json = require "json"
    local data = json.decode(read_json(filename))

    local glyphnames = json.decode(read_json("glyphnames.json"))

    glyphNameToCodepointMap = {}

    for glyph, data in pairs(glyphnames) do
        glyphNameToCodepointMap[glyph] = data.codepoint:sub(3)
    end

    tex.sprint(string.format("{\\setlength{\\baselineskip}{%fpt}", data.pageSetup.lineHeight))

    for _, line in ipairs(data.lines) do
        if #line.elements > 0 then 
            tex.sprint("\\noindent")
        end
        for _, element in ipairs(line.elements) do
            if element.type == 'note' then print_note(element, data.pageSetup) end
            if element.type == 'martyria' then print_martyria(element, data.pageSetup) end
            if element.type == 'dropcap' then print_drop_cap(element, data.pageSetup) end
        end
        if #line.elements > 0 then 
            tex.sprint("\\newline")
        end
        --tex.print("\\end{tikzpicture}")
        --tex.print("\\par")
    end

    tex.sprint("\\par}")
end

function print_note(note, pageSetup)
    tex.sprint("\\mbox{")
    tex.sprint(string.format("\\hspace{%fbp}", note.x)) 
    tex.sprint(string.format("\\makebox[%fbp]{\\fontsize{20bp}{24bp}\\byzfont", note.width))

    if note.measureBarLeft ~= nil then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.measureBarLeft]))
    end

    if note.vareia then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap["vareia"]))
    end

    if note.time ~= nil then
        tex.sprint(string.format("\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}\\hspace{-%fem}", note.timeOffset.x, note.timeOffset.y, glyphNameToCodepointMap[note.time], note.timeOffset.x))
    end

    if note.gorgon ~= nil then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.gorgonDefaultColor, note.gorgonOffset.x, note.gorgonOffset.y, glyphNameToCodepointMap[note.gorgon], note.gorgonOffset.x))
    end

    if note.fthora ~= nil then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.fthoraDefaultColor, note.fthoraOffset.x, note.fthoraOffset.y, glyphNameToCodepointMap[note.fthora], note.fthoraOffset.x))
    end

    if note.accidental ~= nil then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.accidentalDefaultColor, note.accidentalOffset.x, note.accidentalOffset.y, glyphNameToCodepointMap[note.accidental], note.accidentalOffset.x))
    end

    if note.ison ~= nil then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.isonDefaultColor, note.isonOffset.x, note.isonOffset.y, glyphNameToCodepointMap[note.ison], note.isonOffset.x))
    end

    tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.quantitativeNeume]))

    if note.vocalExpression ~= nil then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.vocalExpression]))
    end

    if note.measureBarRight ~= nil then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.measureBarRight]))
    end

    tex.sprint("}");


    if note.lyrics ~= nil then
        local lyricPos = note.alignLeft and "l" or "c"
        tex.sprint(string.format("\\hspace{-%fbp}", note.width - note.lyricsHorizontalOffset))    
        tex.sprint(string.format("\\raisebox{%fbp}{\\makebox[%fbp][%s]{\\fontsize{12bp}{\\baselineskip}\\lyricfont{}%s", pageSetup.lyricsVerticalOffset, note.width - note.lyricsHorizontalOffset, lyricPos, note.lyrics))

        -- Melismas
        if note.melismaWidth > 0 then
            if note.isHyphen then
                for _, hyphenOffset in ipairs(note.hyphenOffsets) do
                    tex.sprint(string.format("\\hspace{%fbp}\\makebox[0pt]{-}\\hspace{-%fbp}", hyphenOffset, hyphenOffset))
                end
            else
                tex.sprint(string.format("\\hspace{%fbp}\\rule{%fbp}{0.75pt}\\hspace{-%fbp}", pageSetup.lyricsMelismaSpacing, note.melismaWidth - pageSetup.lyricsMelismaSpacing, note.melismaWidth))
            end
        end

        tex.sprint("}}")

    end

    tex.sprint(string.format("\\hspace{-%fbp}", note.width))         
    tex.sprint(string.format("\\hspace{%fbp}", -note.x)) 

    tex.sprint("}")
end

function print_martyria(martyria, pageSetup) 
    tex.sprint("\\mbox{")
    tex.sprint(string.format("\\hspace{%fbp}", martyria.x)) 
    tex.sprint(string.format("\\makebox[%fbp]{\\textcolor[HTML]{%s}{\\fontsize{20bp}{\\baselineskip}\\byzfont", martyria.width, pageSetup.martyriaDefaultColor))
    if martyria.measureBarLeft ~= nil then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[martyria.measureBarLeft]))
    end
    tex.sprint(string.format("\\char\"%s\\char\"%s", glyphNameToCodepointMap[martyria.note], glyphNameToCodepointMap[martyria.rootSign]));
    if martyria.measureBarRight ~= nil then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[martyria.measureBarRight]))
    end
    tex.sprint("}}");
    tex.sprint(string.format("\\hspace{-%fbp}", martyria.width))         
    tex.sprint(string.format("\\hspace{%fbp}", -martyria.x)) 
    tex.sprint("}")
end

function print_drop_cap(dropCap, pageSetup) 
    tex.sprint("\\mbox{")
    tex.sprint(string.format("\\hspace{%fbp}", dropCap.x)) 
    tex.sprint(string.format("\\raisebox{%fbp}{\\makebox[%fbp]{\\textcolor[HTML]{%s}{\\fontsize{%fbp}{\\baselineskip}\\dropcapfont{}%s}}}", pageSetup.lyricsVerticalOffset, dropCap.width, dropCap.color, dropCap.fontSize, dropCap.content))
    tex.sprint(string.format("\\hspace{-%fbp}", dropCap.width))         
    tex.sprint(string.format("\\hspace{%fbp}", -dropCap.x)) 
    tex.sprint("}")
end
