--夜鸽学会 蘑菇
function c110000005.initial_effect(c)
	aux.EnablePendulumAttribute(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c110000005.destg)
	e1:SetOperation(c110000005.desop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e2:SetCountLimit(1,110000005)
	e2:SetCondition(c110000005.spcon)
	e2:SetOperation(c110000005.spop)
	c:RegisterEffect(e2)
	
end

function c110000005.desfilter(c)
	return c:IsSetCard(0xfdff) and not c:IsCode(110000005) and c:IsAbleToGrave()
end

function c110000005.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c110000005.desfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,LOCATION_PZONE)
end

function c110000005.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c110000005.desfilter,tp,LOCATION_DECK,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_EFFECT) > 0 then
		Duel.BreakEffect()
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end

function c110000005.inextrafilter(c)
	return c:GetSequence() > 4
end

function c110000005.relfilter(c,tp, ec)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 and ec:GetLocation() == LOCATION_HAND then
		return Duel.IsPlayerCanRelease(tp,c) and c:GetSequence() < 5
	end
	if ec:GetLocation() == LOCATION_EXTRA then
		local g = Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		g = g:Filter(c110000005.inextrafilter,nil)
		if g:GetCount() ~= 0 then return c:GetSequence() > 4 and Duel.IsPlayerCanRelease(tp,c) end
	end
	return Duel.IsPlayerCanRelease(tp,c)
end

function c110000005.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(c110000005.relfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end

function c110000005.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp, c110000005.relfilter, 1, 1, nil, tp,e:GetHandler())
	Duel.Release(g,REASON_RELEASE+REASON_COST)
end