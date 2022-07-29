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
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetCountLimit(1)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c110000006.rtn2tg)
	e2:SetOperation(c110000006.rtn2op)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(110000006,2))
	e3:SetCategory(CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c110000006.atktg)
	e3:SetOperation(c110000006.atkop)
	c:RegisterEffect(e3)
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

function c110000006.rtn2filter(c)
	return (c:GetPreviousLocation() | (LOCATION_DECK+LOCATION_ONFIELD+LOCATION_HAND) ~= 0) and c:GetLocation() == LOCATION_GRAVE
end

function c110000006.rtn2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk == 0 then return eg:IsExists(c110000006.rtn2filter,1,nil) end
	local gc = eg:FilterCount(c110000006.rtn2filter,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE,eg,gc,0,LOCATION_GRAVE)
end

function c110000006.rtn2op(e,tp,eg,ep,ev,re,r,rp)
	local mg = eg:Filter(c110000006.rtn2filter,nil)
	mg = mg:Filter(Card.IsAbleToHand,nil)
	Duel.SendtoHand(mg,nil,REASON_EFFECT)
end

function c110000006.atkfilter(c)
	return c:GetAttack() > 0 and (c:GetPosition() | POS_FACEUP > 0)
end

function c110000006.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk == 0 then return Duel.IsExistingMatchingCard(c110000006.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,tp,LOCATION_MZONE)
end

function c110000006.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg = Duel.GetMatchingGroup(c110000006.atkfilter,tp,0,LOCATION_MZONE,nil)
	local maxatk = 0
	mg,maxatk = mg:GetMaxGroup(Card.GetAttack)
	if mg:GetCount() > 0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(maxatk)
		c:RegisterEffect(e1)
	end
end
