--夜鸽学会的约饭
function c110000003.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,110000003)
	e1:SetCost(c110000003.searchcost)
	e1:SetTarget(c110000003.searchtarget)
	e1:SetOperation(c110000003.searchactivate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,110000003)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c110000003.reccost)
	e2:SetTarget(c110000003.rectarget)
	e2:SetOperation(c110000003.recactivate)
	c:RegisterEffect(e2)
end

function c110000003.disfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0xfdff)
end

function c110000003.searchcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c110000003.disfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
	else Duel.DiscardHand(tp,c110000003.disfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler()) end
end

function c110000003.searchfilter(c)
	return c:IsSetCard(0xfdff) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end

function c110000003.unify(g)
	local result = Group.CreateGroup()
	local card = g:GetFirst()
	while card~=nil
	do
		if not result:IsExists(Card.IsCode,1,nil,card:GetCode())
		then result:AddCard(card)
		end
		card = g:GetNext()
	end
	return result
end


function c110000003.searchtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g = Duel.GetMatchingGroup(c110000003.searchfilter,tp,LOCATION_DECK,0,nil)
		g = c110000003.unify(g)
		if g:GetCount() < 2 then return false else return true end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function c110000003.searchactivate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g = Duel.GetMatchingGroup(c110000003.searchfilter,tp,LOCATION_DECK,0,nil)
	g = c110000003.unify(g)
	if g:GetCount() < 2 then
		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(110000003,0))
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(110000003,1))
	g = g:Select(tp, 2, 2, nil)
	if g:GetCount()==2 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function c110000003.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
	else Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST) end
end

function c110000003.recfilter(c)
	return c:IsSetCard(0xfdff) and c:IsAbleToRemove()
end

function c110000003.rectarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		if chkc then return chkc:GetLocation()==LOCATION_MZONE and chkc:GetControler() == tp and c110000003.recfilter(chkc) end
		return Duel.IsExistingMatchingCard(c110000003.recfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.SelectTarget(tp,c110000003.recfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE+CATEGORY_RECOVER,g,1,tp,LOCATION_MZONE)
end

function c110000003.recactivate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c110000003.retcon)
		e1:SetOperation(c110000003.retop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterFlagEffect(110000003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterEffect(e1,tp)
		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(110000003,2))
		local i = Duel.SelectOption(tp,aux.Stringid(110000003,3),aux.Stringid(110000003,4))
		if i == 0 then
			Duel.Recover(tp, tc:GetAttack(), REASON_EFFECT)
		else
			Duel.Recover(tp, tc:GetDefense(), REASON_EFFECT)
		end
	end
end

function c110000003.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(110000003)~=0
end

function c110000003.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
