--夜鸽学会 小大圣
function c110000002.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,110000002)
	e1:SetCost(c110000002.spcost)
	e1:SetTarget(c110000002.sptarget)
	e1:SetOperation(c110000002.spactivate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,110000002)
	e2:SetTarget(c110000002.reptarget)
	e2:SetValue(c110000002.repvalue)
	e2:SetOperation(c110000002.repoperation)
	c:RegisterEffect(e2)
end

function c110000002.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end

function c110000002.releasefilter(c, tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then
		return Duel.IsPlayerCanRelease(tp,c) and c:GetSequence() < 5
	end
	return Duel.IsPlayerCanRelease(tp,c)
end

function c110000002.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c110000002.releasefilter,tp,LOCATION_MZONE,0,1,nil, tp)
	else 
		local g=Duel.SelectReleaseGroup(tp, c110000002.releasefilter, 1, 1, nil, tp)
		Duel.Release(g,REASON_RELEASE+REASON_COST)
	end
end

function c110000002.searchfilter(c)
	return c:IsSetCard(0xfdff) and c:IsAbleToHand() and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end

function c110000002.spactivate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SpecialSummon(e:GetHandler(),SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP) ~= 0 then
		if Duel.IsExistingMatchingCard(c110000002.searchfilter,tp,LOCATION_DECK,0,1,nil) then
			if Duel.SelectYesNo(tp,aux.Stringid(110000002,0)) then
				local g=Duel.SelectMatchingCard(tp,c110000002.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
				if g:GetCount()>0 then
					Duel.BreakEffect()
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,g)
				end
			end
		end
	end
end

function c110000002.repfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfdff)
		and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
	
end

function c110000002.reptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c110000002.repfilter,1,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local sg=eg:Filter(c110000002.repfilter,nil,tp)
		if sg:GetCount()>1 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(110000002,1))
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end

function c110000002.repvalue(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end

function c110000002.repoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end

