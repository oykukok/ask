# =============================================================================
# Codebase Review Pipeline (Part B)
# Usage:
#   export GROQ_API_KEY=...    # ask scripti bunu kullaniyor
#   make -j                    # paralel calistir
#   make clean                 # uretilen dosyalari sil
# =============================================================================

ASK := ./ask
SRC := codebase.txt

# Final hedef
.PHONY: all clean
all: action.plan.md

# -----------------------------------------------------------------------------
# Phase 1 - FAN-OUT (3 paralel analiz)
# -----------------------------------------------------------------------------

quality.md: $(SRC)
	$(ASK) -s "You are a senior code reviewer focused on code quality." \
	  "Analyze the following code for code quality issues: readability, structure, duplication. \
	   Output exactly 5 to 7 bullets. Each bullet MUST be in the format 'problem -> fix'. \
	   No preamble, no conclusion, only bullets." \
	  < $< > $@

perf.md: $(SRC)
	$(ASK) -s "You are a senior performance engineer." \
	  "Analyze the following code for performance bottlenecks and inefficiencies. \
	   Output exactly 5 to 7 bullets. Each bullet MUST be in the format 'issue -> optimization'. \
	   No preamble, no conclusion, only bullets." \
	  < $< > $@

security.md: $(SRC)
	$(ASK) -s "You are a senior application security engineer." \
	  "Analyze the following code for security vulnerabilities and unsafe patterns. \
	   Output exactly 5 to 7 bullets. Each bullet MUST be in the format 'risk -> mitigation'. \
	   No preamble, no conclusion, only bullets." \
	  < $< > $@

# -----------------------------------------------------------------------------
# Phase 2 - LOCAL SUMMARIZATION (her dali 5 bullet'a sikistir)
# -----------------------------------------------------------------------------

quality.sum.md: quality.md
	$(ASK) -s "You compress technical reports. Output ONLY a markdown bullet list." \
	  "Compress the following into EXACTLY 5 bullets. \
	   Keep only actionable items. Drop anything vague. \
	   Output only the 5 bullets, no headings, no preamble." \
	  < $< > $@

perf.sum.md: perf.md
	$(ASK) -s "You compress technical reports. Output ONLY a markdown bullet list." \
	  "Compress the following into EXACTLY 5 bullets. \
	   Keep only actionable items. Drop anything vague. \
	   Output only the 5 bullets, no headings, no preamble." \
	  < $< > $@

security.sum.md: security.md
	$(ASK) -s "You compress technical reports. Output ONLY a markdown bullet list." \
	  "Compress the following into EXACTLY 5 bullets. \
	   Keep only actionable items. Drop anything vague. \
	   Output only the 5 bullets, no headings, no preamble." \
	  < $< > $@

# -----------------------------------------------------------------------------
# Phase 3 - CONCAT (LLM YOK, sadece shell araclari)
# -----------------------------------------------------------------------------

concatenated.md: quality.sum.md perf.sum.md security.sum.md
	{ \
	  echo "## Code Quality"; \
	  cat quality.sum.md; \
	  echo ""; \
	  echo "## Performance"; \
	  cat perf.sum.md; \
	  echo ""; \
	  echo "## Security"; \
	  cat security.sum.md; \
	} > $@

# -----------------------------------------------------------------------------
# Phase 4 - FAN-IN #1: REFINE (duplicate'leri at, yuksek-sinyal birak)
# -----------------------------------------------------------------------------

refined.md: concatenated.md
	$(ASK) -s "You are a principal engineer producing a refined technical report." \
	  "Refine the following report. \
	   Keep the three sections: Code Quality, Performance, Security. \
	   Remove duplicates across sections. \
	   Keep only high-signal, actionable issues. \
	   Preserve markdown headings (## Code Quality, ## Performance, ## Security). \
	   Output the refined report only." \
	  < $< > $@

# -----------------------------------------------------------------------------
# Phase 5 - FAN-IN #2: FINAL ENGINEERING ACTION PLAN
# -----------------------------------------------------------------------------

action.plan.md: refined.md
	$(ASK) -s "You are a tech lead writing a final engineering action plan." \
	  "Produce a markdown document titled '# Engineering Action Plan' from the following refined report. \
	   It MUST include: \
	   (1) Prioritized actions tagged High / Medium / Low. \
	   (2) An effort estimate per action: Small / Medium / Large. \
	   (3) A clear execution order (numbered). \
	   Use a markdown table or grouped sections. Be concise and concrete." \
	  < $< > $@

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------

clean:
	rm -f quality.md perf.md security.md \
	      quality.sum.md perf.sum.md security.sum.md \
	      concatenated.md refined.md action.plan.md
