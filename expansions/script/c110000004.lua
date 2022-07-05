--夜鸽学会 人鱼
function c110000004.initial_effect(c)
	c:SetSPSummonOnce(110000004)
	--xyz summon
	aux.AddXyzProcedure(c,nil,5,2,c110000004.ovfilter,aux.Stringid(110000004,0),2,nil)
	c:EnableReviveLimit()

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,110000004)
	e1:SetCost(c110000004.searchcost)
	e1:SetTarget(c110000004.searchtarget)
	e1:SetOperation(c110000004.searchactivate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,110000004)
	e2:SetCondition(c110000004.sp2con)
	e2:SetCost(c110000004.searchcost)
	e2:SetTarget(c110000004.sp2target)
	e2:SetOperation(c110000004.sp2activate)
	c:RegisterEffect(e2)
end

function c110000004.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfdff)
end

function c110000004.searchcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function c110000004.searchfilter(c)
	return c:IsSetCard(0xfdff) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end

function c110000004.searchtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c110000004.searchfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function c110000004.spfilter(c,e,tp,code)
	return c:IsSetCard(0xfdff) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end

function c110000004.searchactivate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c110000004.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local c=g:GetFirst()
	if Duel.IsExistingMatchingCard(c110000004.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode()) then
		if Duel.SelectYesNo(tp,aux.Stringid(110000004,1)) then
			local g2=Duel.SelectMatchingCard(tp,c110000004.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,c:GetCode())
			if g2:GetCount()>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

function c110000004.sp2con(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end

function c110000004.sp2filter(c,e,tp)
	return c:IsSetCard(0xfdff) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c110000004.sp2target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		if chkc then return chkc:GetLocation()==LOCATION_GRAVE and c110000004.sp2filter(chkc) and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 end
		return Duel.IsExistingMatchingCard(c110000004.sp2filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
	end
	local g=Duel.SelectTarget(tp,c110000004.sp2filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE+CATEGORY_GRAVE_SPSUMMON,g,1,tp,LOCATION_GRAVE)
end

function c110000004.sp2activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end