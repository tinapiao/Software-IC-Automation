;procedure to generate skill box from point array
procedure(cds_ff_mptFgrComputePointArrayBbox(pointList) let((x0 y0 x1 y1)
    x0 = apply('min foreach(mapcar point pointList car(point)))
    x1 = apply('max foreach(mapcar point pointList car(point)))
    y0 = apply('min foreach(mapcar point pointList cadr(point)))
    y1 = apply('max foreach(mapcar point pointList cadr(point)))
    list(list(x0 y0) list(x1 y1))
)) ;cds_ff_mptFgrComputePointArrayBbox

;procedure to generate point array from skill box
procedure(cds_ff_mptFgrComputePointArrayFromBbox(bbox) let((x0 y0 x1 y1)
    x0 = leftEdge(bbox)
    y0 = bottomEdge(bbox)
    x1 = rightEdge(bbox)
    y1 = topEdge(bbox)
    list(list(x0 y0) list(x1 y0) list(x1 y1) list(x0 y1))
)) ;cds_ff_mptFgrComputePointArrayFromBbox

;procedure to test if horizontal segment path
procedure(cds_ff_mptFgrIsPathHori(path)
    abs(xCoord(car(path)) - xCoord(cadr(path))) > abs(yCoord(car(path)) - yCoord(cadr(path)))
) ;cds_ff_mptFgrIsPathHori

;procedure to test if two bbox's overlap
procedure(cds_ff_mptFgrIsBBoxOverlap(bbox1 bbox2) let(
    ((pt1 car(bbox1))(pt2 cadr(bbox1))(pt3 car(bbox2))(pt4 cadr(bbox2)))
    if(xCoord(pt2) <= xCoord(pt3) || xCoord(pt1) >= xCoord(pt4) || yCoord(pt2) <= yCoord(pt3) || yCoord(pt1) >= yCoord(pt4) nil t)
)) ;cds_ff_mptFgrIsBBoxOverlap

;draw the ring
procedure(cds_ff_mptFgrDrawRing(gr pointList grType vSegWidth hSegWidth vertPitch horizPitch segCnt isRing pin)
    let((
          (pol             cds_ff_mptFgrGetRuleValue("PolyWidth"))
          (poEncY          cds_ff_mptFgrGetRuleValue("PolyExtension"))
          (liL             cds_ff_mptFgrGetRuleValue("Li1Width"))
          (liSP            cds_ff_mptFgrGetRuleValue("Li1Space"))
          (liEncY          cds_ff_mptFgrGetRuleValue("Li1Extension"))
          (meLiV0          cds_ff_mptFgrGetRuleValue("meLiV0"))
          (meImpNDiff      cds_ff_mptFgrGetRuleValue("meImpNDiff"))
          (meImpPDiff      cds_ff_mptFgrGetRuleValue("meImpPDiff"))
          (mwV0            cds_ff_mptFgrGetRuleValue("mwV0"))
          (mlV0            cds_ff_mptFgrGetRuleValue("mlV0"))
          (msV0            cds_ff_mptFgrGetRuleValue("msV0"))
          (meDiffV0        cds_ff_mptFgrGetRuleValue("meDiffV0"))
          (mwViaList       cds_ff_mptFgrGetRuleValue("mwViaList"))
          (mlViaList       cds_ff_mptFgrGetRuleValue("mlViaList"))
          (msViaList       cds_ff_mptFgrGetRuleValue("msViaList"))
          (meMetViaList    cds_ff_mptFgrGetRuleValue("meMetViaList"))
          (meeMetViaList   cds_ff_mptFgrGetRuleValue("meeMetViaList"))
          (topMetList      cds_ff_mptFgrGetRuleValue("topMetList"))
          (topViaList      cds_ff_mptFgrGetRuleValue("topViaList"))
	  (diffLayer       cds_ff_mptFgrGetRuleValue("diffLayer"))
	  (impNLayer       cds_ff_mptFgrGetRuleValue("impNLayer"))
	  (wellNwLayer     cds_ff_mptFgrGetRuleValue("wellNwLayer"))
	  (impPLayer       cds_ff_mptFgrGetRuleValue("impPLayer"))
	  (liLayer         cds_ff_mptFgrGetRuleValue("liLayer"))
	  (v0Layer         cds_ff_mptFgrGetRuleValue("v0Layer"))
	  (polyLayer       cds_ff_mptFgrGetRuleValue("polyLayer"))
	  (polyPurp        cds_ff_mptFgrGetRuleValue("polyPurp"))
	  (finLayer        cds_ff_mptFgrGetRuleValue("finLayer"))
	  (finPurp         cds_ff_mptFgrGetRuleValue("finPurp"))
          (drawPoly        t)
          (drawV0          t)
          (drawFins        t)
	  (drawNW          nil)
          (nseg            0)
	  (cntMet          0)
          (epsilon         0.0001)
          diffShape
          invert
          seg1diffBox
          MKeepOuts
          VKeepOuts
          VMKeepOuts1
          VMKeepOuts2
	  M1KeepOuts
	  V0KeepOuts
	  Li1KeepOuts
	  Li1MKeepOuts
	  metals
          poSP
        )
	poSP = horizPitch - pol
        metals = topMetList
        ;get metal count selected
        while(gr->topMetal != car(metals)
            cntMet = cntMet + 1
            metals = cdr(metals)
        )
        ;process each segment in the point list
        while(cdr(pointList)
            let(((isHoriz nil)
	         (isUp    nil)
	         (isLeft  nil)
	         pt1 pt2 targetPath targetWidth tmpbox
	         meMetVia_1 meMetVia_2 meeMetVia_1 meeMetVia_2
	         adj1 adj2 adj3 adj4 PolyBBox LiBBox V0BBox V1BBox FinBBox diffBox metShape
	         len pitch offset nwShape
	        )
                pt1 = car(pointList)
                pt2 = cadr(pointList)
                nseg = nseg + 1
	        ;determine direction and set width
                if(cds_ff_mptFgrIsPathHori(list(pt1 pt2)) then
                    invert = if(xCoord(pt1) < xCoord(pt2) 1 -1) 
		    isLeft = if(onep(invert) nil t)
		    ;adjust segment length for corner
                    when(nseg > 1 || isRing
                        pt1 = list(xCoord(pt1) - invert * vSegWidth * 0.5 yCoord(pt1))
                    )
                    when(cddr(pointList) || isRing
                        pt2 = list(xCoord(pt2) + invert * vSegWidth * 0.5 yCoord(pt2))
                    )
                    targetWidth = hSegWidth
		    isHoriz = t
                else
                    invert = if(yCoord(pt1) < yCoord(pt2) 1 -1) 
		    isUp = if(onep(invert) t nil)
		    ;adjust segment length for corner
                    when(nseg > 1 || isRing
                        pt1 = list(xCoord(pt1) yCoord(pt1) - invert * hSegWidth * 0.5)
                    )
                    when(cddr(pointList) || isRing
                        pt2 = list(xCoord(pt2) yCoord(pt2) + invert * hSegWidth * 0.5)
                    )
                    targetWidth = vSegWidth
                )
                ;adjust EOL segments
                when(!isRing && (nseg == 1 || nseg == segCnt)
                    if(isHoriz then
                        len = abs(xCoord(pt2) - xCoord(pt1))
                        pitch = horizPitch
                        offset = vSegWidth - (fix(vSegWidth / pitch) * pitch)
                        adj1 = len - ((fix(len / pitch) * pitch) + offset)
                        cond(
                            (segCnt == 1
                                pt2 = list(xCoord(pt2) - invert * adj1 yCoord(pt2))
                            )
                            (nseg == segCnt
                                pt2 = list(xCoord(pt2) - invert * adj1 yCoord(pt2))
                            )
                            (nseg == 1
                                pt1 = list(xCoord(pt1) + invert * adj1 yCoord(pt1))
                            )
                        )
                    else
                        len = abs(yCoord(pt2) - yCoord(pt1))
                        pitch = vertPitch
                        offset = hSegWidth - (fix(hSegWidth / pitch) * pitch)
                        adj1 = len - ((fix(len / pitch) * pitch) + offset)
                        cond(
                            (segCnt == 1
                                pt2 = list(xCoord(pt2) yCoord(pt2) - invert * adj1)
                            )
                            (nseg == segCnt
                                pt2 = list(xCoord(pt2) yCoord(pt2) - invert * adj1)
                            )
                            (nseg == 1
                                pt1 = list(xCoord(pt1) yCoord(pt1) + invert * adj1)
                            )
                        )
                    )
                )
                targetPath = list(pt1 pt2)
	        ;draw difusion
                diffShape = rodCreatePath(?cvId gr->cv ?layer diffLayer ?width targetWidth ?pts targetPath)
                diffShape = diffShape->dbId 
	        diffBox = diffShape->bBox
	        ;keep first segment bbox to add to last segment bbox when closed ring
                when(isRing && (nseg == 1) 
		    seg1diffBox = diffBox
		    ;fill with NWell
		    when(drawNW 
		        nwShape = dbCreatePolygon(gr->cv wellNwLayer pointList)
		    )
		)
	        ;skip first segment of closed ring
                when(!isRing || (isRing && nseg > 1)
	            ;combine the first and last segment of a closed ring
                    when(isRing && (nseg == segCnt)
                        if(isHoriz then
                            diffBox = list(list(min(leftEdge(seg1diffBox) leftEdge(diffBox)) bottomEdge(diffBox))
                                         list(max(rightEdge(seg1diffBox) rightEdge(diffBox)) topEdge(diffBox)))
                        else
                            diffBox = list(list(leftEdge(diffBox) min(bottomEdge(seg1diffBox) bottomEdge(diffBox)))
                                         list(rightEdge(diffBox) max(topEdge(seg1diffBox) topEdge(diffBox))))
                        )
                    )
	            ;draw Poly
	            when(drawPoly
                        PolyBBox = list(list(leftEdge(diffBox) bottomEdge(diffBox) - poEncY) list(leftEdge(diffBox) + pol topEdge(diffBox) + poEncY))
                        while(rightEdge(diffBox) > leftEdge(PolyBBox)
                            dbCreateRect(gr->cv list(polyLayer polyPurp) PolyBBox)
                            PolyBBox = list(list(leftEdge(PolyBBox) + horizPitch bottomEdge(PolyBBox)) list(rightEdge(PolyBBox) + horizPitch topEdge(PolyBBox)))
                        )
	            )
		    ;draw FinArea to display fins
		    when(drawFins
		        FinBBox = list(list(leftEdge(diffBox) bottomEdge(diffBox)) list(rightEdge(diffBox) topEdge(diffBox)))
		        dbCreateRect(gr->cv list(finLayer finPurp) FinBBox)
		    )
	            ;draw metals and create via keepouts from metal keepouts
	            for(i 0 cntMet
	  	        if(i > 0 then
		            VMKeepOuts1 = VMKeepOuts2
		            meMetVia_1 = meMetVia_2
		            meeMetVia_1 = meeMetVia_2
		        else
		            VMKeepOuts1 = nil
		        )
	                MKeepOuts = foreach(mapcar cutbox setof(keepout gr->keepOuts car(keepout) == list(nth(i topMetList) "drawing") && cds_ff_mptFgrIsBBoxOverlap(diffBox cadr(keepout)))
		                        if(isHoriz then
			                    cds_ff_mptFgrComputePointArrayFromBbox(list(list(leftEdge(cadr(cutbox)) bottomEdge(diffBox))
			  	                                              list(rightEdge(cadr(cutbox)) topEdge(diffBox))))
			                else
			                    cds_ff_mptFgrComputePointArrayFromBbox(list(list(leftEdge(diffBox) bottomEdge(cadr(cutbox)))
				                                              list(rightEdge(diffBox) topEdge(cadr(cutbox)))))
			                )
			            )
	                ;save Metal1 keepouts for later use
	                when(i == 0 M1KeepOuts = MKeepOuts)
	                adj1 = if(isHoriz nth(i meeMetViaList) 0)
		        adj2 = if(!isHoriz nth(i meeMetViaList) 0)
		        meMetVia_2 = nth(i meMetViaList)
		        meeMetVia_2 = nth(i meeMetViaList)
		        VMKeepOuts2 = foreach(mapcar cutbox MKeepOuts
		                         tmpbox = cds_ff_mptFgrComputePointArrayBbox(cutbox)
			 	         cds_ff_mptFgrComputePointArrayFromBbox(list(list(leftEdge(tmpbox) - adj1 bottomEdge(tmpbox) - adj2)
				                                           list(rightEdge(tmpbox) + adj1 topEdge(tmpbox) + adj2)))
			              )
	                foreach(mapcar mbox dbPointArrayAndNot(gr->cv list(cds_ff_mptFgrComputePointArrayFromBbox(diffBox)) MKeepOuts) 
		            metShape = dbCreatePolygon(gr->cv nth(i topMetList) mbox)
			    dbAddFigToPin(pin metShape)
		        )
	                ;draw vias greater than V0
	                when(i > 0
		            ;add via keepouts to the metal keepouts
		            VKeepOuts = foreach(mapcar cutbox setof(keepout gr->keepOuts car(keepout) == list(nthelem(i topViaList) "drawing") && cds_ff_mptFgrIsBBoxOverlap(diffBox cadr(keepout))) cds_ff_mptFgrComputePointArrayFromBbox(cadr(cutbox)))
		            VKeepOuts = dbPointArrayOr(gr->cv VMKeepOuts1 VKeepOuts)
	                    VKeepOuts = dbPointArrayOr(gr->cv VMKeepOuts2 VKeepOuts)
	                    adj1 = max(meMetVia_1 meMetVia_2)   ;adjust metal overlap
	                    adj2 = max(meeMetVia_1 meeMetVia_2) ;adjust end of line metal overlap
		            adj3 = hSegWidth + nthelem(i msViaList)       ;adjust for vertical corner
		            adj4 = vSegWidth + nthelem(i msViaList)       ;adjust for horizontal corner
		            cond(
		                ;closed ring horizontal segment
		                (isHoriz && isRing
		                    V1BBox = list(list((leftEdge(diffBox) + adj4) (topEdge(diffBox) - adj1)) list((rightEdge(diffBox) - adj4) (bottomEdge(diffBox) + adj1)))
		                )
		                ;one horizontal segment
		                (isHoriz && segCnt < 2
		                    V1BBox = list(list((leftEdge(diffBox) + adj2) (topEdge(diffBox) - adj1)) list((rightEdge(diffBox) - adj2) (bottomEdge(diffBox) + adj1)))
		                )
		                ;first segment open ring horizontal going left
		                (isHoriz && nseg == 1 && isLeft
		                    V1BBox = list(list((leftEdge(diffBox) + adj4) (topEdge(diffBox) - adj1)) list((rightEdge(diffBox) - adj2) (bottomEdge(diffBox) + adj1)))
		                )
		                ;first segment open ring horizontal going right
		                (isHoriz && nseg == 1 
		                    V1BBox = list(list((leftEdge(diffBox) + adj2) (topEdge(diffBox) - adj1)) list((rightEdge(diffBox) - adj4) (bottomEdge(diffBox) + adj1)))
		                )
		                ;last segment open ring horizontal going left
		                (isHoriz && nseg == segCnt && isLeft
		                    V1BBox = list(list((leftEdge(diffBox) + adj2) (topEdge(diffBox) - adj1)) list((rightEdge(diffBox) - adj4) (bottomEdge(diffBox) + adj1)))
		                )
		                ;last segment open ring horizontal going right
		                (isHoriz && nseg == segCnt
		                    V1BBox = list(list((leftEdge(diffBox) + adj4) (topEdge(diffBox) - adj1)) list((rightEdge(diffBox) - adj2) (bottomEdge(diffBox) + adj1)))
		                )
		                ;middle segment open ring horizontal
		                (isHoriz
		                    V1BBox = list(list((leftEdge(diffBox) + adj4) (topEdge(diffBox) - adj1)) list((rightEdge(diffBox) - adj4) (bottomEdge(diffBox) + adj1)))
		                )
		                ;closed ring vertical segment
		                (isRing 
		                    V1BBox = list(list((leftEdge(diffBox) + adj1) (topEdge(diffBox) - adj3)) list((rightEdge(diffBox) - adj1) (bottomEdge(diffBox) + adj3)))
		                )
		                ;one segment vertical
		                (segCnt < 2 
		                    V1BBox = list(list((leftEdge(diffBox) + adj1) (topEdge(diffBox) - adj2)) list((rightEdge(diffBox) - adj1) (bottomEdge(diffBox) + adj2)))
		                )
		                ;first segment open ring vertical going up
		                (nseg == 1 && isUp 
		                    V1BBox = list(list((leftEdge(diffBox) + adj1) (topEdge(diffBox) - adj3)) list((rightEdge(diffBox) - adj1) (bottomEdge(diffBox) + adj2)))
		                )
		                ;first segment open ring vertical going down
		                (nseg == 1
		                    V1BBox = list(list((leftEdge(diffBox) + adj1) (topEdge(diffBox) - adj2)) list((rightEdge(diffBox) - adj1) (bottomEdge(diffBox) + adj3)))
		                )
		                ;last segment open ring vertical going up
		                (nseg == segCnt && isUp
		                    V1BBox = list(list((leftEdge(diffBox) + adj1) (topEdge(diffBox) - adj2)) list((rightEdge(diffBox) - adj1) (bottomEdge(diffBox) + adj3)))
		                )
		                ;last segment open ring vertical going down
		                (nseg == segCnt
		                    V1BBox = list(list((leftEdge(diffBox) + adj1) (topEdge(diffBox) - adj3)) list((rightEdge(diffBox) - adj1) (bottomEdge(diffBox) + adj2)))
		                )
		                ;middle segment open ring vertical
		                (t
		                    V1BBox = list(list((leftEdge(diffBox) + adj1) (topEdge(diffBox) - adj3)) list((rightEdge(diffBox) - adj1) (bottomEdge(diffBox) + adj3)))
		                )
		            ) ;cond
		            ;draw vias
		            rodFillBBoxWithRects(?cvId gr->cv ?layer nthelem(i topViaList) ?fillBBox V1BBox
		                ?width nthelem(i mwViaList) ?length nthelem(i mlViaList) ?gap "distribute" ?spaceX nthelem(i msViaList) ?spaceY nthelem(i msViaList))
		            ;delete vias when under keepout
		            when(VKeepOuts
		                foreach(vbox VKeepOuts
			            foreach(delShape dbProduceOverlap(gr->cv cds_ff_mptFgrComputePointArrayBbox(vbox) 1 nthelem(i topViaList))
			                dbDeleteObject(delShape)
			            )
			        )
		            )
	                )
	            ) ;end for i cntMet
	            ;create Li1 keepouts from Metal1 keepouts
                    LiBBox = list(list(leftEdge(diffBox) + pol + (poSP - liL) / 2.0 bottomEdge(diffBox))
                                  list(leftEdge(diffBox) + pol + (poSP - liL) / 2.0 + liL topEdge(diffBox)))
	            adj1 = if(isHoriz -meLiV0 0)
	            Li1MKeepOuts = foreach(mapcar cutbox M1KeepOuts
	                              tmpbox = cds_ff_mptFgrComputePointArrayBbox(cutbox)
	                              cds_ff_mptFgrComputePointArrayFromBbox(list(list(leftEdge(tmpbox) - adj1 bottomEdge(tmpbox))
				                                        list(rightEdge(tmpbox) + adj1 topEdge(tmpbox))))
		                  )
	            Li1KeepOuts = foreach(mapcar cutbox setof(keepout gr->keepOuts car(keepout) == list(liLayer "drawing") && cds_ff_mptFgrIsBBoxOverlap(diffBox cadr(keepout))) cds_ff_mptFgrComputePointArrayFromBbox(cadr(cutbox)))
		    Li1KeepOuts = dbPointArrayOr(gr->cv Li1MKeepOuts Li1KeepOuts)
                    ;draw Li1 and V0
                    while(rightEdge(diffBox) > leftEdge(LiBBox)
                        if(Li1KeepOuts then
                            foreach(mapcar li1box dbPointArrayAndNot(gr->cv list(cds_ff_mptFgrComputePointArrayFromBbox(LiBBox)) Li1KeepOuts)
		                tmpbox = cds_ff_mptFgrComputePointArrayBbox(li1box)
		                unless(isHoriz && ((rightEdge(tmpbox) - leftEdge(tmpbox)) < (liL - epsilon))
			            dbCreateRect(gr->cv liLayer list(list(leftEdge(tmpbox) bottomEdge(tmpbox) - liEncY)
			                                           list(rightEdge(tmpbox) topEdge(tmpbox) + liEncY)))
			        )
		            )
                        else
                            dbCreateRect(gr->cv liLayer list(list(leftEdge(LiBBox) bottomEdge(LiBBox) - liEncY)
		                                           list(rightEdge(LiBBox) topEdge(LiBBox) + liEncY)))
                        )
	                when(drawV0
		            ;create V0 keepouts from Metal1 and Li keepouts
		            V0KeepOuts = foreach(mapcar cutbox setof(keepout gr->keepOuts car(keepout) == list(v0Layer "drawing") && cds_ff_mptFgrIsBBoxOverlap(diffBox cadr(keepout))) cds_ff_mptFgrComputePointArrayFromBbox(cadr(cutbox)))
		            V0KeepOuts = dbPointArrayOr(gr->cv Li1KeepOuts V0KeepOuts)
	                    V0KeepOuts = dbPointArrayOr(gr->cv M1KeepOuts V0KeepOuts)
		            adj1 = meDiffV0         ;top/bottom adjust
		            adj2 = -meLiV0        ;left/right edge adjust
		            adj3 = hSegWidth + msV0 ;corner adjust
		            cond(
		                ;horizontal segment
		                (isHoriz
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj1)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj1)))
		                )
		                ;closed ring vertical segment
		                (isRing 
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj3)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj3)))
		                )
		                ;one segment vertical
		                (segCnt < 2
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj1)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj1)))
		                )
		                ;first segment open ring vertical going up
		                (nseg == 1 && isUp 
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj3)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj1)))
		                )
		                ;first segment open ring vertical going down
		                (nseg == 1
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj1)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj3)))
		                )
		                ;last segment open ring vertical going up
		                (nseg == segCnt && isUp
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj1)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj3)))
		                )
		                ;last segment open ring vertical going down
		                (nseg == segCnt
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj3)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj1)))
		                )
		                ;middle segment open ring vertical
		                (t
			            V0BBox = list(list((leftEdge(LiBBox) - adj2) (topEdge(LiBBox) - adj3)) list((rightEdge(LiBBox) + adj2) (bottomEdge(LiBBox) + adj3)))
		                )
		            ) ;end cond
		            ;draw v0
		            rodFillBBoxWithRects(?cvId gr->cv ?layer v0Layer ?fillBBox V0BBox
		                ?width mwV0 ?length mlV0 ?gap "distribute" ?spaceX msV0 ?spaceY msV0)
		            ;delete v0 when under vo keepouts
		            when(V0KeepOuts
		                foreach(v01box V0KeepOuts
		                    foreach(delShape dbProduceOverlap(gr->cv cds_ff_mptFgrComputePointArrayBbox(v01box) 1 v0Layer)
			                dbDeleteObject(delShape)
			            )
		                )
		            )
	                ) ;end when drawV0
                        LiBBox = list(list(leftEdge(LiBBox) + horizPitch bottomEdge(LiBBox)) list(rightEdge(LiBBox) + horizPitch topEdge(LiBBox)))
                    ) ;end while Li
	            ;draw implant
	            adj1 = if(grType == "N" then meImpNDiff else meImpPDiff)
                    tmpbox = list(list(leftEdge(diffBox) - adj1 bottomEdge(diffBox) - adj1) list(rightEdge(diffBox) + adj1 topEdge(diffBox) + adj1))
                    dbCreateRect(gr->cv if(grType == "N" impNLayer impPLayer) tmpbox)
		    ;draw NWell
		    when(drawNW 
		        nwShape = dbCreateRect(gr->cv wellNwLayer tmpbox)
		    )
	        );when first
            ); end let
            pointList = cdr(pointList)
        ) ; end while pointList
    )
) ;cds_ff_mptFgrDrawRing

;body about genlayout
defmethod(vfoSfDraw ((gr cds_ff_mptFgrGuardRing_ver_1)) let(
    (
     (vOffset         cds_ff_mptFgrGetRuleValue("FinWidth"))
     (hOffset         cds_ff_mptFgrGetRuleValue("PolyWidth"))
     (vertSegWidth    gr->verticalSegWidth)
     (horizSegWidth   gr->horizontalSegWidth)
     (vPitch          gr->verticalPitch)
     (hPitch          gr->horizontalPitch)
     (grType          gr->guardRingType)
     segCnt pointList isRing net term pin vSegWidth hSegWidth
    )    
    ;generate ring if path
    if(gr->shapeObj->shapeType == "path" then
        pointList = gr->shapeObj->pointList
    else
        pointList = nil
    )
    ;determine if a closed ring and get segment count
    when(pointList
        isRing = cds_ff_mptFgrClosedRing(pointList)
        segCnt = max(0 (length(pointList) - 1))
    )
    ;create net/terminal/pin "TGR" for binding related shapes to make FGR users(designer/related features like Modgen) 
    ;can assign correct net on it at top design cellview
    net = dbMakeNet(gr->cv gr->termName)
    term = dbCreateTerm(net gr->termName "inputOutput")
    pin = dbCreatePin(net nil gr->termName term)
    vSegWidth = vertSegWidth + hOffset
    hSegWidth = horizSegWidth + vOffset
    ;draw the ring
    cds_ff_mptFgrDrawRing(gr pointList grType vSegWidth hSegWidth vPitch hPitch segCnt isRing pin)
    ;create the fluid shape
    vfoSfRegisterFluidShape(gr
        vfoDrawFluidShape(vfoSfGetShapeObj(gr) gr->cv gr->modelLpp)
    )
)) ;vfoSfDraw
