--夜鸽学会 Omicron
function c110000006.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c110000006.ffilter,3,false)
	
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c110000006.splimit)
	c:RegisterEffect(e0)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(110000006,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c110000006.rtncon)
	e1:SetCost(c110000006.rtncost)
	e1:SetTarget(c110000006.rtntg)
	e1:SetOperation(c110000006.rtnop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(110000006,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCountLimit(1)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c110000006.rtn2con)
	e2:SetTarget(c110000006.rtn2tg)
	e2:SetOperation(c110000006.rtn2op)
	c:RegisterEffect(e2)
end


function c110000006.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xfdff) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode())) and c:IsType(TYPE_MONSTER)
end

function c110000006.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end

function c110000006.rtncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function c110000006.rtncostfilter(c)
   return not (c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_FUSION+REASON_MATERIAL) and c:IsAbleToRemoveAsCost())
end

function c110000006.rtncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetMaterial():FilterCount(c110000006.rtncostfilter, nil)==0
	else 
		Duel.Remove(e:GetHandler():GetMaterial(),POS_FACEUP,REASON_COST)
	end
end

function c110000006.rtntgfilter(c)
	return c:IsPosition(POS_FACEUP) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsSetCard(0xfdff)
end

function c110000006.rtntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c110000006.rtntgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	local mg = Duel.GetMatchingGroup(c110000006.rtntgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,mg,mg:GetCount(),0,LOCATION_MZONE)
end

function c110000006.rtnop(e,tp,eg,ep,ev,re,r,rp)
	local mg = Duel.GetMatchingGroup(c110000006.rtntgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SendtoHand(mg,nil,REASON_EFFECT)
end

function c110000006.rtn2confilter(c)
	return c:GetPreviousLocation() | (LOCATION_DECK+LOCATION_ONFIELD+LOCATION_HAND) ~= 0
end

function c110000006.rtn2con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExistingMatchingCard()
end
