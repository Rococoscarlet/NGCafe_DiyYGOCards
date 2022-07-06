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

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,110000006)
	e3:SetTarget(c110000005.fustg)
	e3:SetOperation(c110000005.fusop)
	c:RegisterEffect(e3)
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

function c110000005.fusfilter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end

function c110000005.fusfilter2(c,e,tp,m,chkf,mf)
	return c:IsSetCard(0xfdff) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf,true) and (not f or f(c))
end

function c110000005.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		local mg=Duel.GetMatchingGroup(c110000005.fusfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
		local res=Duel.IsExistingMatchingCard(c110000005.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf,nil)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c110000005.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,chkf,mf)
			end
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c110000005.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c110000005.fusfilter1),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	local sg1=Duel.GetMatchingGroup(c110000005.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf,nil)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c110000005.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,chkf,mf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end