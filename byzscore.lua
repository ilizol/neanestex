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
    font_metadata = json.decode(read_json("neanes.metadata.json"))

    glyphNameToCodepointMap = {}

    for glyph, data in pairs(glyphnames) do
        glyphNameToCodepointMap[glyph] = data.codepoint:sub(3)
    end

    tex.sprint(string.format("{\\setlength{\\byzneumesize}{%fbp}", data.pageSetup.neumeDefaultFontSize))
    tex.sprint(string.format("{\\setlength{\\byzlyricsize}{%fbp}", data.pageSetup.lyricsDefaultFontSize))
    tex.sprint(string.format("{\\setlength{\\baselineskip}{%fbp}", data.pageSetup.lineHeight))

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
    end

    tex.sprint("\\par}")
end

function print_note(note, pageSetup)
    tex.sprint("\\mbox{")
    tex.sprint(string.format("\\hspace{%fbp}", note.x)) 
    tex.sprint(string.format("\\makebox[%fbp]{\\fontsize{\\byzneumesize}{\\baselineskip}\\byzneumefont", note.width))

    if note.measureBarLeft ~= nil then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.measureBarLeft]))
    end

    if note.vareia then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap["vareia"]))
    end

    if note.time ~= nil then
        local offset = get_mark_offset(note.quantitativeNeume, note.time, note.timeOffset)
        tex.sprint(string.format("\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}\\hspace{-%fem}", offset.x, offset.y, glyphNameToCodepointMap[note.time], offset.x))
    end

    if note.gorgon ~= nil then
        local offset = get_mark_offset(note.quantitativeNeume, note.gorgon, note.gorgonOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.gorgonDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.gorgon], offset.x))
    end

    if note.fthora ~= nil then
        local offset = get_mark_offset(note.quantitativeNeume, note.fthora, note.fthoraOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.fthoraDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.fthora], offset.x))
    end

    if note.accidental ~= nil then
        local offset = get_mark_offset(note.quantitativeNeume, note.accidental, note.accidentalOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.accidentalDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.accidental], offset.x))
    end

    if note.ison ~= nil then
        local offset = get_mark_offset(note.quantitativeNeume, note.ison, note.isonOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.isonDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.ison], offset.x))
    end

    if note.measureNumber ~= nil then
        local offset = get_mark_offset(note.quantitativeNeume, note.measureNumber, note.measureNumberOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.measureNumberDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.measureNumber], offset.x))
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
        tex.sprint(string.format("\\raisebox{%fbp}{\\makebox[%fbp][%s]{\\fontsize{12bp}{\\baselineskip}\\byzlyricfont{}%s", pageSetup.lyricsVerticalOffset, note.width - note.lyricsHorizontalOffset, lyricPos, note.lyrics))

        -- Melismas
        if note.melismaWidth > 0 then
            if note.isHyphen then
                for _, hyphenOffset in ipairs(note.hyphenOffsets) do
                    tex.sprint(string.format("\\hspace{%fbp}\\rlap{-}\\hspace{-%fbp}", hyphenOffset, hyphenOffset))
                end
            else
                tex.sprint(string.format("\\hspace{%fbp}\\rule{%fbp}{%fbp}\\hspace{-%fbp}", pageSetup.lyricsMelismaSpacing, note.melismaWidth - pageSetup.lyricsMelismaSpacing, pageSetup.lyricsMelismaThickness, note.melismaWidth))
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
    tex.sprint(string.format("\\makebox[%fbp]{\\textcolor[HTML]{%s}{\\fontsize{\\byzneumesize}{\\baselineskip}\\byzneumefont", martyria.width, pageSetup.martyriaDefaultColor))
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
    tex.sprint(string.format("\\raisebox{%fbp}{\\makebox[%fbp]{\\textcolor[HTML]{%s}{\\fontsize{%fbp}{\\baselineskip}\\byzdropcapfont{}%s}}}", pageSetup.lyricsVerticalOffset, dropCap.width, dropCap.color, dropCap.fontSize, dropCap.content))
    tex.sprint(string.format("\\hspace{-%fbp}", dropCap.width))         
    tex.sprint(string.format("\\hspace{%fbp}", -dropCap.x)) 
    tex.sprint("}")
end

function get_mark_offset(base, mark, extra_offset)
    local mark_anchor_name = find_mark_anchor_name(base, mark)

    if mark_anchor_name == nil then
      texio.write_nl("warning", "Missing anchor for base: " .. base ..  "mark: " .. mark)
      return { x = 0, y = 0 }
    end

    local mark_anchor = font_metadata.glyphsWithAnchors[mark][
      mark_anchor_name
    ];

    local base_anchor = font_metadata.glyphsWithAnchors[base][
      mark_anchor_name
    ];

    local extra_x = 0
    local extra_y = 0

    if extra_offset ~= nil then
        extra_x = extra_offset.x
        extra_y = extra_offset.y
    end

    return {
      x = base_anchor[1] - mark_anchor[1] + extra_x,
      y = -(base_anchor[2] - mark_anchor[2]) + extra_y,
    }
end

function find_mark_anchor_name(base, mark)
    for anchor_name, _ in pairs(font_metadata.glyphsWithAnchors[mark] or {}) do
        if font_metadata.glyphsWithAnchors[base] and font_metadata.glyphsWithAnchors[base][anchor_name] then
            return anchor_name
        end
    end

    return nil 
end
