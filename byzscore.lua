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

    if note.measureBarLeft then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.measureBarDefaultColor, glyphNameToCodepointMap[note.measureBarLeft]))
    end

    if note.vareia then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap["vareia"]))
    end

    -- If the user specified an additional offset, we must manually position the marks
    if note.timeOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.time, note.timeOffset)
        tex.sprint(string.format("\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}\\hspace{-%fem}", offset.x, offset.y, glyphNameToCodepointMap[note.time], offset.x))
    end

    if note.gorgonOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.gorgon, note.gorgonOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.gorgonDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.gorgon], offset.x))
    end

    if note.gorgonSecondaryOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.gorgonSecondary, note.gorgonSecondaryOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.gorgonDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.gorgonSecondary], offset.x))
    end

    if note.fthoraOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.fthora, note.fthoraOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.fthoraDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.fthora], offset.x))
    end

    if note.fthoraSecondaryOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.fthoraSecondary, note.fthoraSecondaryOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.fthoraDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.fthoraSecondary], offset.x))
    end

    if note.fthoraTertiaryOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.fthoraTertiary, note.fthoraTertiaryOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.fthoraDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.fthoraTertiary], offset.x))
    end

    if note.accidentalOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.accidental, note.accidentalOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.accidentalDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.accidental], offset.x))
    end

    if note.accidentalSecondaryOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.accidentalSecondary, note.accidentalSecondaryOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.accidentalDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.accidentalSecondary], offset.x))
    end

    if note.accidentalTertiaryOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.accidentalTertiary, note.accidentalTertiaryOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.accidentalDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.accidentalTertiary], offset.x))
    end

    if note.isonOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.ison, note.isonOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.isonDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.ison], offset.x))
    end

    if note.noteIndicatorOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.noteIndicator, note.noteIndicatorOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.noteIndicatorDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.noteIndicator], offset.x))
    end

    if note.koronisOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.koronis, note.koronisOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.koronisDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.koronis], offset.x))
    end

    if note.measureNumberOffset then
        local offset = get_mark_offset(note.quantitativeNeume, note.measureNumber, note.measureNumberOffset)
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\hspace{%fem}\\raisebox{-%fem}{\\char\"%s}}\\hspace{-%fem}", pageSetup.measureNumberDefaultColor, offset.x, offset.y, glyphNameToCodepointMap[note.measureNumber], offset.x))
    end

    -- Print the main neume
    tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.quantitativeNeume]))

    if note.vocalExpression then
        tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.vocalExpression]))
    end

    -- If the user did not specify an additional offset, latex+luacolor will position the marks correctly
    if note.time and not note.timeOffset then
            tex.sprint(string.format("\\char\"%s", glyphNameToCodepointMap[note.time]))
    end

    if note.gorgon and not note.gorgonOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.gorgonDefaultColor, glyphNameToCodepointMap[note.gorgon]))
    end

    if note.gorgonSecondary and not note.gorgonSecondaryOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.gorgonDefaultColor, glyphNameToCodepointMap[note.gorgonSecondary]))
    end

    if note.fthora and not note.fthoraOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.fthoraDefaultColor, glyphNameToCodepointMap[note.fthora]))
    end

    if note.fthoraSecondary and not note.fthoraSecondaryOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.fthoraDefaultColor, glyphNameToCodepointMap[note.fthoraSecondary]))
    end

    if note.fthoraTertiary and not note.fthoraTertiaryOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.fthoraDefaultColor, glyphNameToCodepointMap[note.fthoraTertiary]))
    end

    if note.accidental and not note.accidentalOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.accidentalDefaultColor, glyphNameToCodepointMap[note.accidental]))
    end

    if note.accidentalSecondary and not note.accidentalSecondaryOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.accidentalDefaultColor, glyphNameToCodepointMap[note.accidentalSecondary]))
    end

    if note.accidentalTertiary and not note.accidentalTertiaryOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.accidentalDefaultColor, glyphNameToCodepointMap[note.accidentalTertiary]))
    end

    if note.ison and not note.isonOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.isonDefaultColor,glyphNameToCodepointMap[note.ison]))
    end

    if note.noteIndicator and not note.noteIndicatorOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.noteIndicatorDefaultColor,glyphNameToCodepointMap[note.noteIndicator]))
    end

    if note.measureNumber and not note.measureNumberOffset then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.measureNumberDefaultColor, glyphNameToCodepointMap[note.measureNumber]))
    end

    if note.measureBarRight then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.measureBarDefaultColor, glyphNameToCodepointMap[note.measureBarRight]))
    end

    tex.sprint("}");

    if note.lyrics then
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
    tex.sprint(string.format("{\\textcolor[HTML]{%s}{\\fontsize{\\byzneumesize}{\\baselineskip}\\byzneumefont", pageSetup.martyriaDefaultColor))
    
    if martyria.measureBarLeft then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.measureBarDefaultColor, glyphNameToCodepointMap[martyria.measureBarLeft]))
    end
    
    tex.sprint(string.format("\\char\"%s\\char\"%s", glyphNameToCodepointMap[martyria.note], glyphNameToCodepointMap[martyria.rootSign]));
    
    if martyria.measureBarRight then
        tex.sprint(string.format("\\textcolor[HTML]{%s}{\\char\"%s}", pageSetup.measureBarDefaultColor, glyphNameToCodepointMap[martyria.measureBarRight]))
    end

    tex.sprint("}}");
    tex.sprint(string.format("\\hspace{-%fbp}", martyria.width))         
    tex.sprint(string.format("\\hspace{%fbp}", -martyria.x)) 
    tex.sprint("}")
end

function print_drop_cap(dropCap, pageSetup) 
    tex.sprint("\\mbox{")
    tex.sprint(string.format("\\hspace{%fbp}", dropCap.x)) 
    tex.sprint(string.format("\\raisebox{%fbp}{{\\textcolor[HTML]{%s}{\\fontsize{%fbp}{\\baselineskip}\\byzdropcapfont{}%s}}}", pageSetup.lyricsVerticalOffset, dropCap.color, dropCap.fontSize, dropCap.content))    
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

    if extra_offset then
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
